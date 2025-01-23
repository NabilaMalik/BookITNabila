/* eslint-disable no-undef, @typescript-eslint/no-require-imports */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Load email credentials from environment variables
const EMAIL = functions.config().gmail.email;
const PASSWORD = functions.config().gmail.password;

if (!EMAIL || !PASSWORD) {
  throw new Error("Missing Gmail credentials in Firebase Config.");
}

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: EMAIL,
    pass: PASSWORD,
  },
});

/**
 * This function sends an OTP email to the specified email address.
 * @param {object} data - The data object containing the email address.
 * @param {object} context - The context object containing App Check token.
 * @returns {Promise<object>} - A promise that resolves with the success status.
 */
exports.sendOtpEmail = functions.https.onCall(
    {
      enforceAppCheck: true,
    },
    async (data, context) => {
      console.log("sendOtpEmail function called with data:", data);
      const {email} = data;

      if (!email) {
        console.error("Invalid argument: Missing email");
        throw new functions.https.HttpsError(
            "invalid-argument",
            "The function must be called with a valid email.",
        );
      }

      if (!context.app) {
        console.error("Failed precondition: Missing App Check token");
        throw new functions.https.HttpsError(
            "failed-precondition",
            "The function must be called from an App Check verified app.",
        );
      }

      const otp = generateOtp();

      // Store OTP in Firestore
      const otpDocRef = admin.firestore().collection("otps").doc();
      await otpDocRef.set({
        otp: otp,
        email: email,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("OTP stored in Firestore");

      const mailOptions = {
        from: EMAIL,
        to: email,
        subject: "Your OTP Code",
        html: `<p>Your OTP code is <b>${otp}</b></p>`,
      };

      try {
        await transporter.sendMail(mailOptions);
        console.log("Email sent successfully");
        return {success: true, message: "Email sent successfully"};
      } catch (error) {
        console.error("Error sending email:", error);
        throw new functions.https.HttpsError(
            "internal",
            "An error occurred while sending the email.",
            error,
        );
      }
    },
);

/**
 * Generates a 6-digit OTP code.
 * @return {string} - The generated OTP code.
 */
function generateOtp() {
  const digits = "0123456789";
  let otp = "";
  for (let i = 0; i < 6; i++) {
    otp += digits[Math.floor(Math.random() * 10)];
  }
  return otp;
}

/**
 * A simple test function.
 * @param {object} data - The data object containing the message.
 * @param {object} context - The context object.
 * @returns {object} - A response object with a message and the provided data.
 */
exports.testFunction = functions.https.onCall((data) => {
  console.log("Test function called with data:", data);
  return {message: "Test function executed successfully", data: data};
});

/* eslint-enable no-undef, @typescript-eslint/no-require-imports */
