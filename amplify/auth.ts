import { Auth } from "@aws-amplify/backend-auth";

export const auth = new Auth({
  loginWith: {
    phoneNumber: true,
  },
  passwordlessOptions: {
    otp: true,
  },
});
