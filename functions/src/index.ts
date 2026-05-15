import { onCall } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import { defineSecret } from "firebase-functions/params";
import OpenAI from "openai";

setGlobalOptions({ maxInstances: 10 });

// 🔐 Define OpenAI secret once
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");


// ----------------------
// Undertone AI Scan
// ----------------------
export const getBeautyAdvice = onCall(
  { secrets: [OPENAI_API_KEY] },
  async (request) => {

    const openai = new OpenAI({
      apiKey: OPENAI_API_KEY.value(),
    });

    const image = request.data.image;
    const category = request.data.category ?? "makeup";

    if (!image) {
      throw new Error("Image is required.");
    }

    const prompt = `
Analyze the person's face in this image.

Focus only on the visible skin on the face.
Ignore hair, clothing, lighting and background colours.

Determine the skin undertone:
- Warm
- Cool
- Neutral

Then suggest ${category} recommendations suitable for this undertone.

Return ONLY valid JSON in this format:

{
  "undertone": "warm/cool/neutral",
  "confidence": number,
  "lipstick": ["shade1", "shade2"],
  "blush": ["shade1", "shade2"],
  "jewellery": ["type1", "type2"],
  "hairColours": ["colour1", "colour2"]
}
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      response_format: { type: "json_object" },
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: prompt },
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${image}`,
              },
            },
          ],
        },
      ],
    });

    const result = completion.choices[0].message.content ?? "{}";

    return {
      advice: JSON.parse(result),
    };
  }
);


// ----------------------
// Beauty Chat
// ----------------------
export const beautyChat = onCall(
  { secrets: [OPENAI_API_KEY] },
  async (request) => {

    const openai = new OpenAI({
      apiKey: OPENAI_API_KEY.value(),
    });

    const undertone = request.data.undertone ?? "unknown";
    const preferences = request.data.preferences ?? {};
    const messages = request.data.messages ?? [];

    const systemPrompt = `
You are a professional beauty consultant AI.

You help users with:
- makeup
- skincare
- hair
- jewellery
- colour analysis
- beauty routines

User undertone: ${undertone}

User preferences: ${JSON.stringify(preferences)}

Only answer beauty related questions.
Be friendly, concise, and helpful.
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: systemPrompt,
        },
        ...messages,
      ],
    });

    return {
      reply: completion.choices[0].message.content ?? "",
    };
  }
);