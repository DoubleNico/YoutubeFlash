import cors from "cors";
import express from "express";
import ffmpeg from "fluent-ffmpeg";
import fs from "fs";
import path from "path";
import youtubeDl from "youtube-dl-exec";

import { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = 3000;

app.use(cors("*"));

app.get("/", (req, res) => {
  res.send("Welcome to my server!");
  console.log(req);
  console.log(res);
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

app.get("/download/mp4", async (req, res) => {
  console.log("Download started as mp4");
  const URL = req.query.URL;
  const name = req.query.name;
  console.log(URL);
  console.log(name);

  try {
    const output = await youtubeDl(URL, {
      format: "mp4",
      output: `${name}.mp4`,
      noCheckCertificates: true,
      noWarnings: true,
      preferFreeFormats: true,
      addHeader: ["referer:youtube.com", "user-agent:googlebot"],
    });

    console.log("Download finished as mp4");
    // Send the downloaded video as mp4 to the client
    const filePath = path.join(__dirname, `${name}.mp4`);
    res.download(filePath, (err) => {
      if (err) {
        console.error("Error during file sending:", err);
        res.status(500).json({ success: false, error: "File sending failed" });
      } else {
        fs.unlinkSync(filePath); // delete the file after sending it
      }
    });
  } catch (error) {
    console.error("Error during download:", error);
    res.status(500).json({ success: false, error: "Download failed" });
  }
});

app.get("/download/mp3", async (req, res) => {
  console.log("Download started as mp3");
  const URL = req.query.URL;
  const name = req.query.name;
  console.log(URL);
  console.log(name);

  try {
    const output = await youtubeDl(URL, {
      format: "bestaudio",
      output: `${name}_conversion.mp3`,
      noCheckCertificates: true,
      noWarnings: true,
      preferFreeFormats: true,
      addHeader: ["referer:youtube.com", "user-agent:googlebot"],
    });
    console.log("Download finished as mp3");

    ffmpeg(`${name}_conversion.mp3`)
      .output(`${name}.mp3`)
      .on("end", function () {
        console.log("conversion ended");
        const filePath = path.join(__dirname, `${name}.mp3`);
        res.download(filePath, (err) => {
          if (err) {
            console.error("Error during file sending:", err);
            res
              .status(500)
              .json({ success: false, error: "File sending failed" });
          } else {
            fs.unlinkSync(filePath); // delete the file after sending it
          }
        });
      })
      .run();
  } catch (error) {
    console.error("Error during download:", error);
    res.status(500).json({ success: false, error: "Download failed" });
  }
});
