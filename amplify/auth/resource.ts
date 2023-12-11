import { defineAuth } from "@aws-amplify/backend";

export const auth = defineAuth({
  loginWith: {
    phone: true,
  },
  passwordlessAuth: {
    otp: {
      sms: {
        originationNumber: "+18888747169",
      },
    },
  },
});
