import { Client } from "minio";

const minioClient = new Client({
  endPoint: "10.13.29.36",    // or LAN IP if needed
  port: 9000,
  useSSL: false,
  accessKey: process.env.MINIO_ROOT_USER || "minioadmin",
  secretKey: process.env.MINIO_ROOT_PASSWORD || "minioadmin",
});

export default minioClient;
