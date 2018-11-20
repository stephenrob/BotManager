require 'set'

module BotManager

  module Alexa

    class InteractionModelBuilder

      def to_h

        {
            interactionModel: {
                languageModel: {
                    invocationName: "",
                    intents: [
                        {
                            name: "",
                            samples: [
                                ""
                            ]
                        },
                        {
                            name: "",
                            samples: [
                                ""
                            ],
                            slots: [
                                {
                                    name: "",
                                    type: "",
                                    samples: [
                                        ""
                                    ]
                                }
                            ]
                        }
                    ],
                    types: [
                        {
                            name: "",
                            values: [
                                {
                                    name: {
                                        value: ""
                                    }
                                }
                            ]
                        }
                    ]
                },
                dialog: {
                    intents: [
                        {
                            name: "",
                            confirmationRequired: false,
                            prompts: {},
                            slots: [
                                {
                                    name: "",
                                    type: "",
                                    confirmationRequired: false,
                                    elicitationRequired: true,
                                    prompts: {
                                        elicitation: ""
                                    },
                                    validations: [
                                        {
                                            type: "",
                                            prompt: "",
                                            values: [
                                                ""
                                            ]
                                        },
                                        {
                                            type: "",
                                            prompt: ""
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                prompts: [
                    {
                        id: "Elicit.Intent-INTENT_NAME.IntentSlot-SLOT_NAME",
                        variations: [
                            {
                                type: "",
                                value: ""
                            }
                        ]
                    },
                    {
                        id: "Slot.Validation.596358663326.282490667310.1366622834897",
                        variations: [
                            {
                                type: "",
                                value: ""
                            }
                        ]
                    }
                ]
            }
        }

      end

    end

  end

end