import { Auth } from "@aws-amplify/backend-auth";

export const auth = new Auth({
  loginWith: {
    email: true,
  },
  passwordlessAuth: {
    otp: {
      destination: "SMS",
      length: 6,
    },
  },
});
