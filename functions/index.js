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
 * @returns {Promise<object>} - A promise that resolves with the success status.
 */
exports.sendOtpEmail = functions.https.onCall(async (data) => {
  const {email} = data;

  if (!email) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The function must be called with a valid email.",
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

  const mailOptions = {
    from: EMAIL,
    to: email,
    subject: "Your OTP Code",
    html: `
      <html>
        <body>
          <p>Your OTP code is <b>${otp}</b></p>
        </body>
      </html>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return {success: true, message: "Email sent successfully"};
  } catch (error) {
    throw new functions.https.HttpsError(
        "internal",
        "An error occurred while sending the email.",
        error,
    );
  }
});

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

/* eslint-enable no-undef, @typescript-eslint/no-require-imports */
