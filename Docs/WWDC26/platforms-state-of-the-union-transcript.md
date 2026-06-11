# WWDC26 Platforms State of the Union - Full Transcript

- **Source:** Apple Developer, June 8, 2026
- **Video:** https://www.youtube.com/live/yl2jsIoMfDU
- **Duration:** 1:01:39
- **Method:** English captions supplied with the video, normalized into timestamped prose.
- **Accuracy note:** Technical product names were retained from the supplied captions. Caption punctuation and occasional recognition errors may remain; consult Apple documentation before copying API names into code.

## Transcript

**[00:00:19]** Welcome to the 2026 Platforms State of the Union.

**[00:00:23]** This is one of our favorite moments of the year where we get to share what's new

**[00:00:28]** with the technologies, the frameworks, and the tools that you use every day

**[00:00:32]** to build incredible apps and games.

**[00:00:35]** Apps that inspire us, that raise the bar of what's possible

**[00:00:39]** and that push us to build even better technologies.

**[00:00:44]** We love connecting with so many of you.

**[00:00:47]** Hearing about your passions, your challenges,

**[00:00:50]** and how we can better support your work.

**[00:00:53]** Your feedback shapes some of the most important technologies that we build.

**[00:00:57]** And this past year, nowhere was that more true than with the new design

**[00:01:02]** with Liquid Glass and with Apple Intelligence.

**[00:01:05]** These were both huge themes in the 26 releases, and they're key again this year,

**[00:01:11]** with many of our efforts influenced by your feedback.

**[00:01:14]** Design and intelligence are both so important because they enhance

**[00:01:19]** what's special about your apps.

**[00:01:22]** The care and the craft that you put into them.

**[00:01:26]** With unique interfaces and rich experiences

**[00:01:29]** shaped by your deep domain expertise.

**[00:01:33]** Combined with enhanced intelligence capabilities, you can now build features

**[00:01:37]** that weren't previously possible.

**[00:01:39]** To highlight what's new, we'll dive into three key areas.

**[00:01:43]** First, Apple Intelligence, with new ways to bring generative intelligence

**[00:01:48]** directly into your apps, and new integrations

**[00:01:51]** with system intelligence to bring users back to your apps.

**[00:01:55]** Second, platform improvements, with design refinements and more flexible UI layout,

**[00:02:00]** updates to Swift and SwiftUI, and enhancements that make your apps faster,

**[00:02:06]** more adaptive, and easier to build.

**[00:02:09]** And finally, developer productivity, taking agentic coding even further,

**[00:02:14]** alongside improvements that make Xcode faster and more personal.

**[00:02:18]** We have a lot to cover, so let's get started with Apple Intelligence.

**[00:02:23]** At the heart of Apple Intelligence are Apple Foundation models.

**[00:02:27]** Working together with Google and leveraging the technologies

**[00:02:30]** behind their Gemini family of models,

**[00:02:33]** we created the latest Apple Foundation models

**[00:02:36]** to power our Apple Intelligence experiences and toprovide even better support

**[00:02:41]** for the ways you're using intelligence in your apps.

**[00:02:44]** We adapted these models to run on device and on Private Cloud Compute.

**[00:02:49]** Apple Foundation Models power Apple intelligence, and your apps can use them

**[00:02:53]** too, through the Foundation Models framework.

**[00:02:56]** This year, the framework's capabilities are expanding to include image input and

**[00:03:00]** support for server models.

**[00:03:03]** So if you have a more complex task

**[00:03:05]** requiring the most advanced frontier models

**[00:03:08]** the API can now integrate with the cloud model provider of your choice.

**[00:03:13]** To ensure getting started with a large cloud model is as accessible as possible,

**[00:03:18]** even if you're writing your first app,

**[00:03:20]** developers with fewer than 2 million first-time App Store downloads

**[00:03:24]** will be able to use Apple Foundation Models

**[00:03:26]** running in Private Cloud Compute with no cloud API cost.

**[00:03:30]** It's access to frontier level intelligence with unparalleled privacy protections.

**[00:03:37]** Because getting started exploring ideas

**[00:03:39]** shouldn't be held back by infrastructure costs.

**[00:03:43]** With these enhancements, the Foundation Models framework now offers a single API

**[00:03:48]** that supports any model you need.

**[00:03:50]** In addition to features you build within your apps, Apple Intelligence can also

**[00:03:55]** surface your app in more places across the system,

**[00:03:58]** giving users more ways to discover and return to it.

**[00:04:02]** The App Intents framework connects your app to Apple Intelligence,

**[00:04:05]** drawing on core operating system technologies,

**[00:04:08]** like the Spotlight semantic index.

**[00:04:11]** It organizes and surfaces personal context from any supported app.

**[00:04:15]** The app toolbox, which identifies features

**[00:04:18]** available across apps to serve a user request.

**[00:04:21]** And the system orchestrator, which coordinates it all

**[00:04:24]** while protecting user privacy.

**[00:04:26]** Together, in-app and system-wide intelligence unlock experiences that

**[00:04:31]** neither could deliver alone.

**[00:04:33]** Your apps made more powerful by intelligence.

**[00:04:37]** And intelligence made more meaningful by your apps.

**[00:04:41]** Let's dive into these frameworks and see how they'll transform

**[00:04:44]** what your apps can do.

**[00:04:46]** Here's Richard and Mary Beth.

**[00:04:51]** The Foundation Models framework is a native Swift API

**[00:04:54]** that gives you direct access

**[00:04:56]** to the same on-device model that powers Apple intelligence.

**[00:04:59]** And many of you have already adopted it, creating experiences for shopping apps

**[00:05:04]** like Wayfair, educational apps like CellWalk,

**[00:05:07]** local sports apps like CricHeroes and more,

**[00:05:10]** all running on device with no infrastructure costs

**[00:05:13]** or privacy trade-offs.

**[00:05:15]** It's amazing to see how you've pushed the limits of what an on-device model can do.

**[00:05:20]** We've got exciting updates for you.

**[00:05:22]** Let's start with a preview of the intelligence-powered features

**[00:05:25]** you will be able to build today.

**[00:05:26]** Mary Beth, over to you.

**[00:05:28]** This year, we're building a sample app all about the Japanese paper craft of origami.

**[00:05:34]** It's a place to unwind and get creative with paper.

**[00:05:37]** I'll give you a quick tour.

**[00:05:38]** Our app starts with a beautiful gallery of my origami projects.

**[00:05:42]** And what's special about these is that I've used foundation models

**[00:05:46]** to tailor origami projects to match a person's interests and materials

**[00:05:50]** with step-by-step feedback.

**[00:05:52]** Of course, it's more fun to craft with friends.

**[00:05:55]** So our app has a built-in chat.

**[00:05:57]** It's a fun focused place to plan meetups and talk about crafting.

**[00:06:01]** Now I'm working on a cool feature to combine people's interests

**[00:06:04]** into an origami project.

**[00:06:06]** Here, I'll take this paper Rachel's bringing and mix in a photo of my dog

**[00:06:12]** to generate a fun project for us all to fold together.

**[00:06:15]** With Foundation Models framework, my app analyzes the inspiration pictures

**[00:06:19]** to get a sense of the materials I have and this dog theme I have in mind.

**[00:06:23]** It even translates the Japanese text and uses all of this context

**[00:06:27]** to brainstorm a few options.

**[00:06:30]** I'll choose this one.

**[00:06:32]** The intelligence keeps going in a fully interactive tutorial.

**[00:06:36]** That's a quick preview.

**[00:06:38]** Let's talk about the framework.

**[00:06:40]** This year, we're taking the Foundation Models framework

**[00:06:43]** to the next level.

**[00:06:44]** First, you get new capabilities like multimodal prompts with text and images.

**[00:06:50]** This opens up new categories of experiences you can build

**[00:06:54]** with image understanding.

**[00:06:56]** It's as simple as attaching an image to your prompt.

**[00:07:00]** In addition to this, the Vision framework is now integrated,

**[00:07:03]** giving you purpose-built tools the model can use,

**[00:07:06]** such as OCR for precise text extraction,

**[00:07:09]** and barcode readers for quick code scanning all on-device.

**[00:07:14]** Next, let's talk about server models.

**[00:07:17]** On-device models are incredibly useful for many tasks.

**[00:07:20]** Yet sometimes you might want a larger model for a more complex workflow.

**[00:07:25]** That's why we're extending the framework so you can easily call server models

**[00:07:29]** like Claude, Gemini, and more

**[00:07:32]** to use features like tool calling and guided generation.

**[00:07:35]** And any model provider can create a Swift package that conforms

**[00:07:39]** to the Language Model protocol.

**[00:07:41]** So you can pick the one you want for your app.

**[00:07:44]** In addition to this, we're opening up access for those of you

**[00:07:47]** getting started with AI to use the Apple Foundation Model

**[00:07:50]** running on Private Cloud Compute with no cloud API cost,

**[00:07:55]** giving you access to frontier-level intelligence

**[00:07:58]** while ensuring your user's data is not stored or accessible

**[00:08:01]** to Apple or anyone else.

**[00:08:04]** Your users will have access to features leveraging the cloud model every day,

**[00:08:09]** and iCloud+ subscribers will have expanded access.

**[00:08:12]** No matter the model you want to use, you can easily swap it in.

**[00:08:16]** This makes the Foundation Models framework

**[00:08:19]** the best way to run any large language model in your app.

**[00:08:23]** With more modalities and more models at your fingertips,

**[00:08:26]** the next thing you'll need is more ways to put them to work.

**[00:08:29]** That's why we're introducing a new open source Swift package,

**[00:08:33]** loaded with pre-built tools to help you get started

**[00:08:36]** with concepts like skills and utilities for context management.

**[00:08:41]** For example, a task management app like Tiimo can use the package

**[00:08:45]** to pull in a skill that adapts its tone and recommendations to the user's data,

**[00:08:50]** delivering a personalized brief to help them stay on top of their day.

**[00:08:54]** This space evolves so quickly.

**[00:08:57]** Tomorrow's abstractions may be very different from today's.

**[00:09:00]** So these utilities from the open source package are created

**[00:09:04]** with new fundamental building blocks called Dynamic Profiles.

**[00:09:08]** These are new declarative APIs in the Foundation Models framework

**[00:09:13]** for building truly adaptive AI experiences with less code,

**[00:09:17]** so you can orchestrate skills and sub-agents,

**[00:09:20]** swap tools in and out, and update instructions on the fly.

**[00:09:25]** I'll walk you through how Dynamic Profiles powers intelligence in the Origami app.

**[00:09:29]** First, let's open Xcode.

**[00:09:31]** I'll start with a LanguageModelSession, which many of you already use.

**[00:09:35]** Now, instead of creating a session with a fixed model, tools, and instructions,

**[00:09:40]** with Dynamic Profiles,

**[00:09:42]** you have the freedom to continuously update your session.

**[00:09:45]** So I'll choose a profile for the LanguageModelSession

**[00:09:48]** and start with the familiar Swift result builder syntax.

**[00:09:52]** Here in the body, I'll define my first Profile as a brainstorming helper

**[00:09:56]** that's going to generate project ideas based on the photos I give it.

**[00:10:00]** I'll add modifiers to use Private Cloud Compute language model

**[00:10:04]** with temperature cranked up for creativity.

**[00:10:07]** Now the beauty of a Dynamic Profile is that this body will always resolve

**[00:10:10]** to just one Profile driving my session at a time,

**[00:10:13]** but I can switch between as many Profiles

**[00:10:16]** as my feature needs in the same session.

**[00:10:20]** So I'll change Profile based on my app state.

**[00:10:23]** Then I can add in a second Profile to handle tutorial generation.

**[00:10:28]** Using Private Cloud Compute again with reasoning level set to deep,

**[00:10:32]** since this is my most challenging task.

**[00:10:35]** Last, I'll add in a Profile that explains any origami jargon, like "valley fold",

**[00:10:40]** that the user doesn't understand.

**[00:10:42]** This is a nice smaller task.

**[00:10:44]** I can send the on-device SystemLanguageModel

**[00:10:46]** to save on server calls.

**[00:10:48]** Let's see it in action.

**[00:10:50]** Here in my tutorial, I can now tap this term I don't understand,

**[00:10:53]** and the on-device model generates a nice explanation.

**[00:10:57]** In Dynamic Profiles, I'm swapping out models,

**[00:10:59]** but everything shares the same continuous transcript.

**[00:11:02]** This means more contextual intelligence with less prompting.

**[00:11:06]** Now let's use that in my Tutorial Profile.

**[00:11:09]** Instructions and tools can be swapped in and out as well.

**[00:11:12]** So I'll use my app's view model to check if the tutorial's been generated,

**[00:11:16]** and if so, I'll add in instructions and tools to help the model

**[00:11:20]** give high-quality feedback tailored to the user.

**[00:11:23]** This body recomputes on every model turn, so my session will stay up to date.

**[00:11:28]** Finally, do you see how my three Origami Profiles look a bit like three AI agents?

**[00:11:34]** That's because Dynamic Profiles are designed to be adaptable building blocks.

**[00:11:38]** So if you want to build AI agents or skills

**[00:11:41]** or any other high-level abstraction, you can.

**[00:11:45]** With the focus of flexibility and composability, these new APIs

**[00:11:49]** from the Foundation Models framework are here to grow with you.

**[00:11:52]** To help you bring all of this to your apps,

**[00:11:55]** you'll have access to a complete set of tools,

**[00:11:57]** from building to testing, to shipping with confidence.

**[00:12:00]** That includes the new Evaluations framework,

**[00:12:04]** which gives you the ability to test your prompts and validate

**[00:12:07]** that your intelligence-powered features work reliably.

**[00:12:10]** The upgraded Foundation Models instrument will help you visualize and debug

**[00:12:15]** model behavior in your apps.

**[00:12:17]** And the new FM command line tool lets you prompt the model right from the terminal.

**[00:12:23]** And there's so much more, like a Python SDK,

**[00:12:26]** tool calling with images, and a new RAG tool

**[00:12:29]** powered by Core Spotlight that's private to your app.

**[00:12:32]** That's the Foundation Models framework, providing you seamless access to

**[00:12:37]** multiple models with all new capabilities in the native Swift API.

**[00:12:41]** Plus, we're doing something big.

**[00:12:44]** Later this summer, the framework will be open source.

**[00:12:48]** So the same Swift APIs you use in your app can now run on your server too,

**[00:12:54]** giving you a complete end-to-end AI workflow anywhere you deploy Swift.

**[00:12:58]** You've seen how the Foundation Models framework connects to third-party models,

**[00:13:02]** Private Cloud Compute, and the on-device model.

**[00:13:05]** You have the flexibility you need to get the right model for the job.

**[00:13:08]** And when you want to bring a specific model into your app and run it on device,

**[00:13:13]** there's Core AI.

**[00:13:15]** Core AI is a brand new framework built right into the platform,

**[00:13:19]** along with supporting tools and technologies.

**[00:13:22]** It's designed to be the best way to bring and run models on device in your apps.

**[00:13:28]** It delivers uncompromising performance through a modern memory-safe Swift API,

**[00:13:32]** with extensive tuning capabilities from fine-grained interest management

**[00:13:37]** and model specialization to custom GPU kernels.

**[00:13:41]** And there are Python-based tools alongside the framework, so you can convert

**[00:13:44]** and optimize your PyTorch models for the Core AI runtime.

**[00:13:48]** The framework is backed by deep integration

**[00:13:50]** into a new developer toolchain,

**[00:13:52]** with ahead-of-time compilation, dedicated Core AI instruments,

**[00:13:56]** and a powerful visual debugger to trace tensor values

**[00:13:59]** directly back to your original Python source code.

**[00:14:03]** And it's engineered to scale with your available compute.

**[00:14:07]** So you can run a compact vision model in your iPhone app

**[00:14:10]** for real-time camera queries.

**[00:14:12]** Or deploy a multi-billion parameter LLM in a Mac app right at your desk

**[00:14:17]** to power an agentic assistant for complex, multi-step workflows.

**[00:14:22]** Whatever the device, whatever the model, it all runs on-device

**[00:14:26]** with zero server dependencies and zero token costs.

**[00:14:30]** Core AI is optimized for performance on Apple silicon,

**[00:14:33]** and it empowers Apple Intelligence experiences

**[00:14:36]** across the system, including Siri.

**[00:14:38]** And this year, Apple Intelligence offers even more opportunities for developers.

**[00:14:44]** Over to Lori.

**[00:14:45]** Apple Intelligence draws on personal context from across apps,

**[00:14:49]** understands what's on screen, and can take actions to get things done.

**[00:14:53]** And now you can integrate with its capabilities

**[00:14:55]** through the App Intents framework.

**[00:14:57]** It's how our platforms understand what your apps can do.

**[00:15:00]** With it, you can make your app's content easier to find

**[00:15:03]** and its capabilities easier to use

**[00:15:05]** through the Action button, Shortcuts, widgets, and in Siri AI.

**[00:15:10]** App Intents schemas make integration with Siri's capabilities easy.

**[00:15:14]** Schemas are recognizable structures that Siri understands deeply,

**[00:15:18]** built on years of language model training.

**[00:15:21]** We provide entity schemas

**[00:15:23]** for describing the content and concepts your app works with,

**[00:15:26]** and intent schemas for describing the actions it can perform.

**[00:15:30]** Entity schemas enable personal context understanding.

**[00:15:33]** By contributing your app's content to the Spotlight semantic index,

**[00:15:37]** you can help your users find information from your app quickly and easily

**[00:15:41]** with attribution back to your app.

**[00:15:43]** The indexing keys for important content properties are built right in,

**[00:15:47]** which means more understanding from less code.

**[00:15:49]** Siri's understanding of intent schemas means people can make requests naturally.

**[00:15:54]** They don't need to learn specific phrases

**[00:15:56]** and you don't have to define them in your code.

**[00:15:58]** Schemas cover common app categories

**[00:16:01]** like task management, photo editing, and communication,

**[00:16:04]** and include a whole set of system-supported actions.

**[00:16:06]** Just adopt the relevant intent schemas for the actions your app can perform

**[00:16:10]** to make them available to your users.

**[00:16:13]** And because these schemas are system-defined,

**[00:16:15]** they'll benefit from future updates.

**[00:16:17]** That means as Siri's language understanding evolves

**[00:16:20]** or as we add new support for languages or regional dialects,

**[00:16:23]** your intents will work there too, without any changes to your code.

**[00:16:27]** Combining these capabilities with the new View Annotations API will let your users

**[00:16:31]** reference and take action on the content in your app when it's on screen.

**[00:16:35]** So your users can interact with your app conversationally,

**[00:16:38]** saying what feels natural to them, not commands they have to memorize.

**[00:16:42]** Now, I'm going to show you how we've made our Origami app work with Siri.

**[00:16:46]** I already have some entities and intents that describe my app's content

**[00:16:50]** and actions, and the entities conform to the IndexedEntity protocol,

**[00:16:54]** so they can be indexed into Spotlight.

**[00:16:56]** By also conforming to an entity schema, Siri will be able to discover and reason

**[00:17:00]** over my app's content.

**[00:17:02]** I'll make sure my Message, Contact, and Conversation entities all conform

**[00:17:06]** to the relevant entity schemas by using the @AppEntity macro.

**[00:17:10]** I'm indexing these entities into Spotlight when my app finishes launching

**[00:17:14]** to make sure everything's in sync.

**[00:17:16]** I've rebuilt to get the latest changes, and now let's see what I can do,

**[00:17:19]** even when I'm not in the app.

**[00:17:21]** Hey Siri, who's coming to origami night?

**[00:17:31]** Siri: Based on your messages in Origami, it looks like Kevin, Mary Beth, Rachel,

**[00:17:35]** and Richard are discussing origami night.

**[00:17:38]** What's Richard bringing?

**[00:17:42]** Siri: Richard mentioned he is thinking of bringing pizza.

**[00:17:44]** Awesome.

**[00:17:45]** But now I want to follow up, which means I need to act on this information.

**[00:17:49]** I can make the content Siri found actionable by conforming an intent

**[00:17:53]** to the sendMessage schema.

**[00:17:55]** This time I'm using the @AppIntent macro,

**[00:17:57]** since this is an action rather than content.

**[00:18:00]** I'll build and run again, and now I can say, Siri, text Richard,

**[00:18:05]** "Can you make one of the pizzas vegetarian?"

**[00:18:10]** Siri: From Origami: Ready to send it?

**[00:18:13]** Yes.

**[00:18:15]** Siri: It's sent.

**[00:18:17]** Great. Message sent.

**[00:18:18]** I'd also like to let people reference what's on screen in my app

**[00:18:21]** just by saying "the second message" or "this photo".

**[00:18:24]** The new View Annotations API lets me associate my views with entities,

**[00:18:28]** which can then be passed to my app's intents, making them actionable.

**[00:18:32]** My Message List view contains all the individual messages in a conversation.

**[00:18:36]** I can use a new view modifier to map each message row

**[00:18:39]** to its respective MessageEntity.

**[00:18:42]** Let's try it out.

**[00:18:44]** Hey Siri, send this photo to Kevin and say,

**[00:18:47]** "Rachel got us some paper to practice our folds.

**[00:18:50]** What color would you like?"

**[00:18:58]** Siri: From Origami: Ready to send it?

**[00:19:00]** Yes.

**[00:19:02]** Siri: It's sent.

**[00:19:04]** And Siri sends the photo with my message.

**[00:19:06]** By combining personal context, common app actions,

**[00:19:09]** and on-screen awareness,

**[00:19:11]** your app can become part of the intelligent fabric of the system.

**[00:19:14]** Through Siri, users can access it through natural language,

**[00:19:17]** discover it through semantic search,

**[00:19:19]** and integrate it into their daily workflows.

**[00:19:21]** Now, back to Josh.

**[00:19:26]** This is our vision for an intelligent platform.

**[00:19:29]** Rich, native experiences and intelligent natural language interfaces

**[00:19:33]** working together.

**[00:19:35]** As app developers, this represents an incredible opportunity.

**[00:19:39]** You can enhance your app's experiences through natural language with Siri,

**[00:19:43]** build powerful AI features with the Foundation Models framework,

**[00:19:47]** and even run your own models on-device with Core AI.

**[00:19:52]** If you're using a custom model to power a feature within your app,

**[00:19:56]** Core AI is the right technology to use.

**[00:19:59]** Your models will perform efficiently across all devices,

**[00:20:03]** and it's built into the platform, so your apps always benefit

**[00:20:06]** from the latest fixes and enhancements.

**[00:20:10]** And if you're an enthusiast who is experimenting with, training, researching,

**[00:20:14]** or fine-tuning generative models, or if you're running a local inference server,

**[00:20:19]** our array framework, MLX, makes it easy to explore

**[00:20:23]** cutting-edge innovations and technologies.

**[00:20:26]** It now supports Metal 4, GPU Neural Accelerators, and it can even scale

**[00:20:31]** training across multiple Macs with RDMA over Thunderbolt.

**[00:20:36]** It's all open source and it's faster than ever.

**[00:20:40]** The breadth of capabilities offered by Apple Intelligence and powered by

**[00:20:44]** Apple silicon makes Apple's platforms the best place to build and deliver

**[00:20:49]** the next generation of intelligence-enhanced apps and games.

**[00:20:53]** Now let's take a look a level deeper at what makes all of this possible -

**[00:20:58]** the systems your apps depend on, from the frameworks you call

**[00:21:01]** to the processes that schedule your work, manage your memory, and render your UI.

**[00:21:07]** We took an especially close look at the performance and quality

**[00:21:10]** of these foundations, and you'll see a multitude of platform improvements

**[00:21:14]** in this year's releases.

**[00:21:16]** When you rebuild with the new SDK, your apps will launch faster

**[00:21:20]** and feel more responsive.

**[00:21:22]** You'll see refinements and platform improvements across frameworks media,

**[00:21:27]** search, and accessibility, enhancements to Swift and SwiftUI, and a lot more,

**[00:21:33]** especially around design.

**[00:21:35]** Last year, the new design with Liquid Glass

**[00:21:38]** brought a unified design language

**[00:21:40]** built for a world where your experience moves across devices.

**[00:21:44]** The new design is making apps more expressive and delightful

**[00:21:48]** while staying instantly familiar to users.

**[00:21:51]** It looks great in apps like Tide Guide, where subtle, interactive highlights

**[00:21:56]** respond as users scroll through tide data and charts.

**[00:22:00]** And SketchPro, where translucent brush panels and controls

**[00:22:03]** let artwork show through, even while you switch between tools.

**[00:22:08]** Throughout the last year, we've been refining the design,

**[00:22:11]** and that journey continues

**[00:22:12]** with a new set of design updates in the 27 releases.

**[00:22:16]** Apps that have already adopted Liquid Glass benefit

**[00:22:19]** from many of these improvements automatically.

**[00:22:22]** To tell you more, here's Cindy.

**[00:22:26]** In this year's releases, you'll see updates to the foundations

**[00:22:29]** of how Liquid Glass is built, refinements to the new design

**[00:22:33]** that improve consistency, and new ways for iOS apps

**[00:22:37]** to adapt across devices and screen sizes.

**[00:22:40]** Let's review the changes you'll see in your apps.

**[00:22:43]** To maintain exceptional readability, we tuned Liquid Glass

**[00:22:46]** so it more effectively diffuses complex content behind it.

**[00:22:50]** And to establish more depth and separation, we also introduced

**[00:22:54]** a darkened edge along with brighter specular highlights.

**[00:22:57]** We also made it more personalizable with a new slider in settings

**[00:23:01]** to adjust Liquid Glass anywhere from ultra clear to fully tinted,

**[00:23:05]** allowing users to choose the look that works best for them.

**[00:23:09]** Apps already using Liquid Glass get these improvements automatically

**[00:23:12]** when they run on this year's releases without even needing to recompile.

**[00:23:16]** Liquid Glass seamlessly adapts to a variety of accessibility settings

**[00:23:20]** users may choose, such as reducing transparency or increasing contrast.

**[00:23:25]** And now macOS 27 also supports the "show borders" environment value,

**[00:23:30]** just like iOS.

**[00:23:32]** So you can adapt your macOS app's custom controls for this setting as well.

**[00:23:37]** Sidebars expand to the edges on Mac and iPad, providing clearer structure

**[00:23:41]** while still refracting content from your app and the wallpaper.

**[00:23:45]** And icons in the sidebar regain their color using your app's accent color,

**[00:23:50]** giving your app more personality and making it more clear which window is key.

**[00:23:54]** List and Label APIs provide these updates automatically

**[00:23:58]** and support customizing the tint per item.

**[00:24:01]** And every window on macOS now also has the same tighter corner radius,

**[00:24:06]** ensuring greater consistency across all apps.

**[00:24:10]** When content scrolls under floating bars, a uniform toolbar appears across the top

**[00:24:15]** and keeps the text legible while improving contrast.

**[00:24:18]** This effect is applied automatically for standard toolbars

**[00:24:22]** and can be customized using the existing scroll edge effect APIs.

**[00:24:27]** We also thought about how icons and menus can be used intentionally

**[00:24:31]** to call attention to the most important actions,

**[00:24:34]** both on macOS and iPadOS.

**[00:24:36]** While icons are hidden by default, there's an API to show icons

**[00:24:40]** for key app actions.

**[00:24:42]** We're also updating how Liquid Glass shows up in icons,

**[00:24:46]** making them sharper and more defined.

**[00:24:48]** This updated rendering applies to all app icons,

**[00:24:52]** and we've introduced new features such as refraction

**[00:24:55]** that can be selectively used for added character.

**[00:24:59]** And with Icon Composer, you can now design your icons

**[00:25:02]** out of multiple layers of Liquid Glass.

**[00:25:04]** It's been updated with new annotation features to add refraction

**[00:25:08]** or dial in Liquid Glass content effects.

**[00:25:11]** And it provides an interactive preview of how your icon will look

**[00:25:15]** on earlier releases.

**[00:25:17]** Together, these updates culminate in a more focused and approachable experience

**[00:25:21]** across your apps and across platforms.

**[00:25:25]** Next, let's talk about app adaptability.

**[00:25:28]** iOS apps show up in more places than ever,

**[00:25:31]** on iPad as an iPhone app, or on Mac through iPhone Mirroring.

**[00:25:35]** When your iOS app shows up in these other contexts with larger displays,

**[00:25:40]** users want to be able to take advantage of the extra space

**[00:25:44]** to see more information.

**[00:25:45]** So this year we're introducing support to resize iOS apps

**[00:25:49]** in iPhone Mirroring and on iPad.

**[00:25:52]** Let's see how this works with the Origami app.

**[00:25:55]** Once you rebuild with the latest SDK,

**[00:25:57]** your app is automatically opted in to resizability.

**[00:26:00]** Since Origami is a SwiftUI app, it's already taking advantage

**[00:26:04]** of scene lifecycle and standard framework support for basic resizability.

**[00:26:08]** If you're already using SwiftUI, Auto Layout, or responding to

**[00:26:12]** size class changes, you are well on your way

**[00:26:14]** to supporting full resizability.

**[00:26:17]** If you have custom views, you'll want to update them to using auto layout

**[00:26:20]** and trait collections for layout decisions.

**[00:26:23]** Using the new resizable iOS simulator and Previews,

**[00:26:27]** you can test across a variety of screen sizes right in Xcode,

**[00:26:31]** so you'll see exactly how your layout performs.

**[00:26:34]** And we're providing a skill for coding agents that will help you find and fix

**[00:26:38]** common resizability issues.

**[00:26:40]** Now, instead of designing for specific devices and orientations,

**[00:26:44]** you're designing for a dynamic range of sizes and aspect ratios.

**[00:26:49]** To provide the best experience when using iPhone Mirroring,

**[00:26:52]** update your app to be able to adapt and support any size.

**[00:26:57]** Resizable simulator, Previews, and iPhone Mirroring all make it easy

**[00:27:01]** to ensure your app is as dynamic and flexible as possible.

**[00:27:05]** Next, let's talk about SwiftUI.

**[00:27:08]** Here's Franck.

**[00:27:09]** SwiftUI is the best way to build apps for any Apple device.

**[00:27:14]** We designed SwiftUI to capture everything we know

**[00:27:18]** about building great apps on our platforms.

**[00:27:21]** It gracefully handles the complexities

**[00:27:23]** of layout, animation, and platform integration

**[00:27:27]** so you can focus on what makes your app yours.

**[00:27:31]** And as new capabilities like Liquid Glass are added, apps get these features easily

**[00:27:38]** because they're designed with SwiftUI in mind.

**[00:27:41]** New apps like The Goat are built with SwiftUI

**[00:27:44]** because they want to feel truly at home on Apple platforms.

**[00:27:48]** The Goat is a game development environment that brings the open source Godot engine

**[00:27:52]** to Apple devices.

**[00:27:54]** It started on iPad, expanded to iPhone, and when the time came to bring it to Mac,

**[00:27:59]** it felt completely natural.

**[00:28:01]** And apps that previously used cross-platform or web technologies

**[00:28:05]** like Notion are migrating their user interface to SwiftUI

**[00:28:10]** because they want a level of performance and UI consistency

**[00:28:14]** that other technologies can't deliver.

**[00:28:17]** With powerful agentic coding tools, porting code to Swift

**[00:28:22]** has never been easier.

**[00:28:23]** Of course, we reach for SwiftUI ourselves whenever we build apps.

**[00:28:29]** For example, SwiftUI made it easy to build a new Siri app by enabling us

**[00:28:34]** to share code across all our platforms and Creator Studio apps like Logic Pro,

**[00:28:40]** build new features with SwiftUI for high performance

**[00:28:44]** and cross-platform support.

**[00:28:46]** Since we rely on SwiftUI ourselves, every improvement we make for our own apps

**[00:28:52]** becomes an improvement for your apps too.

**[00:28:55]** And this is a big year for SwiftUI.

**[00:28:58]** With richer interactions that help you write less custom code,

**[00:29:02]** with speed making your apps much faster,

**[00:29:06]** and finally, with new capabilities for your apps.

**[00:29:10]** Let's start with interactions.

**[00:29:12]** This year, SwiftUI brings more dynamic interactions to your app

**[00:29:17]** like reorderable containers, which makes it super easy

**[00:29:20]** to add drag to reorder to any container.

**[00:29:23]** Building a grid reordering experience outside of lists, like with this grid

**[00:29:28]** in the Origami app, used to require a lot of code.

**[00:29:33]** Now, it is just as simple as adding .reorderable() to your ForEach

**[00:29:38]** and .reorderContainer() to the parent.

**[00:29:41]** And just like that, I can customize the order of my Origami models.

**[00:29:46]** SwiftUI handles the lift and the drop animations and it works with any container

**[00:29:52]** like grids and stacks.

**[00:29:54]** Now, for Origami models I feel a little less proud of,

**[00:29:59]** SwiftUI now supports swipe actions inside any container as well.

**[00:30:03]** I can delete a custom row with a swipe

**[00:30:06]** by adding the existing .swipeActions() modifier to my row

**[00:30:10]** and .swipeActionsContainer() to the scrollable container.

**[00:30:13]** This provides great flexibility for quick actions on my custom row.

**[00:30:18]** Finally, text selection got more flexible too.

**[00:30:22]** On iOS, it gains the same. full-fidelity selection

**[00:30:27]** already found in TextField and TextEditor.

**[00:30:31]** And on macOS, it now supports custom text renderers, text vibrancy,

**[00:30:36]** and vertical text.

**[00:30:38]** Next, let's take a look at speed.

**[00:30:41]** This is always a priority for us, but even more so this year,

**[00:30:46]** and you will see many improvements without any changes on your end.

**[00:30:50]** To start, we've been gradually unifying the architectures of SwiftUI, AppKit,

**[00:30:56]** and UIKit, and this year, they share a common foundation across many controls.

**[00:31:02]** So wherever your app is running,

**[00:31:04]** they can benefit from the same on-the-line improvements.

**[00:31:08]** For example, menu pickers on macOS

**[00:31:11]** are now better equipped to smoothly handle large lists of items.

**[00:31:16]** And in nested stack layouts,

**[00:31:18]** whereas SwiftUI used to measure each child multiple times

**[00:31:22]** to resolve their flexibility, it now short-circuits computations

**[00:31:26]** where they're not needed,

**[00:31:28]** meaning layouts now resize up to twice as fast.

**[00:31:31]** And nothing saves performance like avoiding unnecessary work.

**[00:31:36]** SwiftUI now only initializes state objects when they're first loaded.

**[00:31:41]** Previously, a new temporary instance of the state object would get created

**[00:31:47]** every time the view is reinitialized.

**[00:31:49]** You get this improvement for free because state is now lazy under the hood

**[00:31:54]** and was converted from a dynamic property to a macro.

**[00:31:59]** And when it comes to loading images, AsyncImage avoids redundancies as well.

**[00:32:04]** It now caches its content automatically using standard HTTP caching,

**[00:32:10]** so images are downloaded once and only re-fetched when needed.

**[00:32:14]** Finally, let's talk about new capabilities starting with toolbars.

**[00:32:19]** With the new resizability features, optimizing your app for a dynamic range

**[00:32:24]** of sizes and aspect ratios is more important than ever.

**[00:32:30]** And toolbars are central to that experience.

**[00:32:33]** This year, SwiftUI gives you finer control over how toolbar items adapt to space.

**[00:32:40]** Use the new visibilityPriority modifier to mark your most important items high.

**[00:32:46]** And SwiftUI keeps them visible longer as space shrinks.

**[00:32:50]** Less prominent actions, like archive or delete, can be added to

**[00:32:55]** the new toolbars overflow menu container, which groups them in an overflow menu.

**[00:33:00]** And finally, the new topBarPinnedTrailing placement anchors items

**[00:33:05]** to the trailing edge, no matter how the toolbar reflows.

**[00:33:09]** Now, when I resize the window, the toolbar stays organized exactly how I want.

**[00:33:14]** Important buttons stay visible.

**[00:33:17]** Deprioritized ones are in the overflow menu and share is always pinned

**[00:33:23]** to the trailing edge.

**[00:33:24]** Tabs can also be distinguished with the new prominent tab role

**[00:33:29]** pinning the tab to the trailing edge of the screen.

**[00:33:32]** SwiftUI also opens up new ground for document-based apps

**[00:33:37]** with a new document infrastructure that provides a ton of functionality

**[00:33:42]** out of the box, like first-class URL access

**[00:33:45]** for fully customizable reading and writing to disk,

**[00:33:49]** the kind that powers apps like Xcode or Pages.

**[00:33:53]** For example, with direct access to the file URL, you now have the flexibility

**[00:33:59]** to read just the parts of a file you need and write only the pieces that changed,

**[00:34:04]** not the entire file.

**[00:34:06]** You can also observe and update document attributes

**[00:34:09]** using the provided observable configuration.

**[00:34:12]** The new document API integrates deeply with modern Swift,

**[00:34:16]** with support for observation, Swift concurrency, and so much more.

**[00:34:22]** Lastly, here is something pretty awesome.

**[00:34:26]** The Spatial Preview framework gives Mac apps new ways

**[00:34:29]** to extend in space around users wearing Apple Vision Pro.

**[00:34:33]** When you adopt this new API in your app, a 3D model can become spatial

**[00:34:38]** when you stream to Apple Vision Pro, allowing your users to preview, edit,

**[00:34:44]** and share objects and models in real time.

**[00:34:48]** Beyond those we've mentioned already, there are many other new improvements,

**[00:34:52]** including better type checking performance with content builders,

**[00:34:56]** a new alert binding API, and to support adjusting cross-fade transitions.

**[00:35:02]** Together, these platform improvements bring more speed, richer interactions, and

**[00:35:08]** powerful new capabilities to SwiftUI that you can take advantage of.

**[00:35:13]** Now, let's take a look at Swift itself.

**[00:35:16]** Here's Holly.

**[00:35:18]** Swift is designed to be the language you reach for at every layer of the stack.

**[00:35:23]** Whether you're building full-featured mobile apps, internet-scale services, or

**[00:35:27]** embedded firmware, Swift helps you write code that's fast, expressive, and safe.

**[00:35:33]** Swift's performance, depth, and unmatched interoperability make it the natural

**[00:35:38]** successor to C and C++ for low-level systems and server programming.

**[00:35:43]** And its approachability and expressiveness make it ideal for higher-level development

**[00:35:48]** like apps and frameworks.

**[00:35:50]** We think Swift is the only language with this breadth.

**[00:35:54]** That's what makes Swift a language you can keep reaching for as your stack grows.

**[00:35:59]** Including outside Apple platforms, where the tools for development on Linux,

**[00:36:03]** Windows, Android, and the web are available on Swift.org.

**[00:36:08]** Many of you are extending your use of Swift to additional platforms

**[00:36:12]** and the server so you can reuse code and benefit from Swift's high performance

**[00:36:17]** across your entire stack, like Flighty, which uses Swift in their services

**[00:36:22]** to share the code that tracks airport visits

**[00:36:24]** between the app and backend.

**[00:36:26]** Or GoodNotes, which uses Swift for WebAssembly to bring the app to the web,

**[00:36:31]** Chrome OS, Android, and Windows, reusing over 100,000 lines of code.

**[00:36:37]** Or Frameo, which uses Swift-Java interoperability to share Swift libraries

**[00:36:41]** between the iOS app and the PhotoFrame software written in Java.

**[00:36:46]** Interoperability means you can bring Swift into C, C++, and Java systems

**[00:36:51]** you already have.

**[00:36:53]** So you can get Swift's benefits at every layer without a rewrite.

**[00:36:57]** At Apple, we've been building with Swift at every layer of our own stack.

**[00:37:02]** Foundation paved the way for Objective-C frameworks

**[00:37:05]** to move to native Swift under the hood.

**[00:37:07]** AppKit and UIKit have followed suit by using Swift and SwiftUI extensively

**[00:37:12]** in their implementation.

**[00:37:14]** WebKit, the open source web engine that powers Safari,

**[00:37:17]** is a large and security-critical C++ code base.

**[00:37:21]** Using Swift's safe C++ interoperability, WebKit is replacing core components

**[00:37:27]** with Swift versions incrementally.

**[00:37:29]** In the networking stack, the QUIC transport layer was rewritten in Swift.

**[00:37:34]** Later this month, the project will be open sourced and available

**[00:37:37]** for cross-platform use hrough SwiftNIO integration.

**[00:37:41]** You can follow along or get involved

**[00:37:43]** through the vibrant open source community on Swift.org.

**[00:37:47]** Further down the stack, more security and performance critical systems

**[00:37:50]** moved to Swift this year.

**[00:37:52]** The TrueType font rendering engine replaced decades of hand-optimized C

**[00:37:57]** with Swift code that's not only memory safe, but also faster.

**[00:38:02]** At the lowest level, we've written hundreds of thousands of lines

**[00:38:05]** of Swift code across bare metal firmware, coprocessors, and drivers.

**[00:38:10]** For the 27 releases, we've started writing parts of the core operating system kernel

**[00:38:15]** in Swift.

**[00:38:17]** As Swift becomes more capable in these domains, we're staying true

**[00:38:20]** to one of Swift's most important design goals:

**[00:38:24]** it's fun.

**[00:38:26]** It's natural to write and iterate on your ideas in Swift, and the compiler is there

**[00:38:30]** to catch mistakes along the way.

**[00:38:33]** The latest updates are focused on improving your workflow

**[00:38:36]** so you can focus on the fun part:

**[00:38:38]** writing great code with confidence.

**[00:38:41]** Swift 6.4 is here, built to make everyday tasks feel effortless.

**[00:38:46]** I'll show you just a few examples.

**[00:38:48]** When your code base is undergoing a migration or incremental adoption

**[00:38:52]** of new features, sometimes it's not realistic to address all compiler warnings

**[00:38:57]** across your project at once.

**[00:38:59]** You can now suppress warnings in specific parts of your code, and you can promote

**[00:39:04]** warnings to errors in places where you want strict enforcement.

**[00:39:08]** Availability attributes can get long and repetitive when you're writing code

**[00:39:12]** for multiple Apple platforms.

**[00:39:14]** Now, instead of listing out every Apple platform with the same version number,

**[00:39:19]** you can simply write 'anyAppleOS'.

**[00:39:21]** The limitation on async calls in a defer block is gone,

**[00:39:25]** and awaiting inside a defer just works.

**[00:39:29]** No matter what you're building, Swift's compiler diagnostics

**[00:39:32]** are a daily companion, helping you catch mistakes early

**[00:39:35]** and guiding you toward correct code.

**[00:39:38]** If you've spent time writing Swift code,

**[00:39:40]** you've probably encountered this error message:

**[00:39:43]** "The compiler is unable to type check this expression in reasonable time."

**[00:39:48]** This can happen in complex operator expressions, closures,

**[00:39:51]** or in deeply nested SwiftUI view bodies.

**[00:39:55]** This is frustrating, and we've made it a lot better.

**[00:39:59]** In many common cases, code that hit this fallback error will now either

**[00:40:03]** compile successfully or give you a more actionable error to work with.

**[00:40:08]** We know this area is important for a smooth workflow,

**[00:40:11]** and we're continuing to invest in it.

**[00:40:13]** Swift 6.4 makes you more productive in day-to-day code,

**[00:40:17]** and it brings that same care to the more specialized corners

**[00:40:20]** of your project.

**[00:40:21]** There's never been a better time to go full stack with Swift.

**[00:40:25]** Now back to Josh.

**[00:40:28]** So those are the platform improvements in this year's releases.

**[00:40:32]** Now, to move ahead, sometimes we have to leave something behind.

**[00:40:36]** As we said last year, macOS Tahoe was the final release to support Intel Macs.

**[00:40:42]** The transition of macOS to Apple silicon is now complete, enabling us to focus

**[00:40:47]** on a single architecture across the entire ecosystem.

**[00:40:51]** This can benefit your apps as well.

**[00:40:53]** You can now ship Apple silicon-only binaries on the Mac App Store,

**[00:40:57]** reducing your app's download size and letting you focus your testing

**[00:41:01]** on a single architecture.

**[00:41:03]** And with all the refinements to the new design with Liquid Glass,

**[00:41:06]** it's time to complete your migration there too.

**[00:41:09]** We'll be removing support for opting to use the old design.

**[00:41:13]** So once your app is recompiled with Xcode 27, it will automatically

**[00:41:17]** begin to use the new design with Liquid Glass.

**[00:41:21]** With so many improvements across the system, your apps and games

**[00:41:25]** will look and feel better than ever on this year's releases.

**[00:41:29]** Now, let's turn to your productivity and the tools you use

**[00:41:33]** to build with and for our platforms.

**[00:41:36]** Intelligence is deeply transforming how you write code,

**[00:41:39]** add new features, and build apps.

**[00:41:42]** Last year, we brought AI coding assistance to Xcode,

**[00:41:45]** and so many of you embraced it immediately.

**[00:41:49]** It's helping you write code faster and adopt new APIs more easily.

**[00:41:54]** This space moves really fast, so we've picked up the pace of our releases,

**[00:41:59]** delivering new Xcode capabilities to you faster than ever before.

**[00:42:03]** Earlier this year, we brought coding agents to Xcode, along with tools allowing

**[00:42:08]** agents to grab a preview, search documentation, and more,

**[00:42:12]** powered by the Model Context Protocol.

**[00:42:15]** With MCP, Xcode also connects to the tools you already use,

**[00:42:19]** from design apps like Figma to services like GitHub.

**[00:42:24]** And Xcode includes a built-in integration for agents from Anthropic, OpenAI,

**[00:42:29]** and now Google.

**[00:42:31]** Today, Xcode adds support for Agent Client Protocol,

**[00:42:34]** so you can bring any compatible agent into Xcode.

**[00:42:38]** ACP support and Gemini integration

**[00:42:40]** are shipping in an update to Xcode 26 available today.

**[00:42:44]** And there's more coming in Xcode 27.

**[00:42:47]** Here's Ken.

**[00:42:49]** From the first line of code to the App Store,

**[00:42:51]** Xcode is where you build the best apps for Apple platforms.

**[00:42:55]** Millions of you live in it for writing and debugging your code

**[00:42:57]** with coding agents right alongside,

**[00:43:00]** designing interfaces in SwiftUI and previewing them in real time,

**[00:43:04]** testing across devices and simulators to catch issues before your users do,

**[00:43:09]** and profiling performance with instruments, keeping your apps fast,

**[00:43:13]** responsive, and efficient.

**[00:43:16]** This year, Xcode has two big stories.

**[00:43:18]** The first is intelligence, and we have a lot to talk about in a minute.

**[00:43:23]** The second is the daily experience, how Xcode feels to use.

**[00:43:28]** Now just like you, we spend hours in Xcode every day.

**[00:43:33]** We build all our operating systems and apps with it.

**[00:43:36]** In fact, we build Xcode with Xcode.

**[00:43:40]** So it needs to feel like home while being fast, fun, and personal.

**[00:43:45]** And we've heard your feedback and improved Xcode across the board.

**[00:43:49]** It's faster at loading projects.

**[00:43:51]** We fixed top crashes and spins.

**[00:43:54]** Debug sessions are more reliable, with faster expression evaluation,

**[00:44:00]** and a console that can handle more intensive logging without hitching.

**[00:44:04]** Xcode 27 is 30% smaller.

**[00:44:07]** Now, Apple silicon-only,

**[00:44:09]** with agents, documentation, and other components downloading in the background,

**[00:44:14]** so you're always up to date.

**[00:44:16]** Now, let's take a look at the experience.

**[00:44:18]** First, your Xcode settings are now automatically saved to iCloud.

**[00:44:23]** When I'm setting up a new Mac like this, Xcode offers to import them.

**[00:44:27]** I'll pull in the settings from my iMac.

**[00:44:29]** I can sign in with my Apple ID.

**[00:44:32]** Xcode fills in my Git config too.

**[00:44:34]** And just like that, I'm ready to code with my new Mac.

**[00:44:38]** Now, let's create a new project. Watch this.

**[00:44:40]** I'll select new project, then app and boom, I'm in the editor.

**[00:44:46]** No file name, no bundle ID, no setup.

**[00:44:50]** Of course I can specify all those things later when I'm ready.

**[00:44:54]** This is great for exploring an idea, a new API, or prototyping a view.

**[00:45:00]** Alright, now I'll open the Origami project.

**[00:45:04]** Xcode 27 looks beautiful with the design refinements of macOS 27.

**[00:45:10]** Crisp and clean. Let's customize it.

**[00:45:14]** In Xcode 27, you can make the toolbar your own.

**[00:45:17]** It's easy to rearrange things, so I can add what I need and remove what I don't.

**[00:45:22]** The activity view is now tucked neatly into the document title over here,

**[00:45:26]** so there's even more room for the things I want.

**[00:45:30]** The navigation buttons, canvas toggle, editor splits,

**[00:45:32]** they're all right up here on the toolbar.

**[00:45:35]** Now I'll add a shortcut to quickly create a new coding assistant conversation

**[00:45:39]** and that'll be useful a little bit later.

**[00:45:42]** Next and super fun, themes.

**[00:45:46]** Color now flows throughout the entire app, not just the editor.

**[00:45:50]** You can personalize everything from the background to syntax colors

**[00:45:54]** and dial in that perfect shade of purple for your keywords.

**[00:45:57]** And Xcode 27 comes with gorgeous new choices.

**[00:46:01]** Let me show you a few of my favorites.

**[00:46:03]** Emerald. That feels fresh.

**[00:46:05]** You can almost smell it.

**[00:46:07]** How about something with a little bit more energy?

**[00:46:10]** Neon Noir. Electric. Love it.

**[00:46:15]** Light or dark? Every theme supports both.

**[00:46:18]** Here's Coral Reef. I feel relaxed already.

**[00:46:22]** And when I'm working on multiple projects at the same time,

**[00:46:24]** I can set a different theme for each.

**[00:46:27]** Makes it super easy to tell them apart at a glance.

**[00:46:30]** All right, let's get back to work.

**[00:46:32]** Next, Xcode Cloud, which gives you continuous integration and delivery

**[00:46:36]** built right into Xcode.

**[00:46:38]** I'll set up my Origami project to use it.

**[00:46:41]** I'll click get started, grant access to my repository, and that's it.

**[00:46:46]** I can kick off my first cloud build.

**[00:46:48]** No App Store Connect setup needed.

**[00:46:51]** And Xcode Cloud builds are up to twice as fast,

**[00:46:55]** now supporting Apple Vision Pro and apps using Metal on Apple silicon.

**[00:47:00]** Next, Previews.

**[00:47:02]** They are the best way to iterate on UI and the easiest way to see

**[00:47:07]** how your views look across variants, like accessibility sizes, orientations,

**[00:47:11]** and localizations.

**[00:47:13]** And now you can see variations for any property.

**[00:47:16]** I'll open this view here that shows a craft note.

**[00:47:19]** It renders differently based on the CraftState enum,

**[00:47:22]** which has four different values.

**[00:47:24]** Now, I can pass that enum to the preview and just like that -

**[00:47:28]** I get a grid showing all the states of my UI.

**[00:47:31]** All four in one glance.

**[00:47:34]** Next, another one I'm excited about.

**[00:47:36]** When testing your app, you use real hardware to evaluate performance,

**[00:47:40]** use sensors, and test real-world conditions.

**[00:47:44]** And you use simulators to cover older OSes and devices that you don't have.

**[00:47:49]** Xcode 27 brings both together in the new Device Hub.

**[00:47:54]** It replaces Simulator and it does a whole lot more too.

**[00:47:58]** Let me show you.

**[00:47:59]** When I first run my app, the window looks like the Simulator I know.

**[00:48:03]** I can easily rotate, grab a screenshot and jump back to the home screen,

**[00:48:09]** just like I'm used to.

**[00:48:11]** When I extend the view, I can now change device properties

**[00:48:14]** and test how my app responds to different system settings.

**[00:48:18]** Like switching to dark mode, increasing the font size, and more.

**[00:48:22]** We rebuilt the experience from the ground up for the highest fidelity possible.

**[00:48:27]** So I can pinch to zoom, use two-finger scrolling, and like in Previews,

**[00:48:32]** I can dynamically resize the simulator to see how my iOS app

**[00:48:36]** handles different sizes.

**[00:48:38]** I can also manage and interact with physical devices from the same place,

**[00:48:42]** like this iPhone here on my desk.

**[00:48:44]** I'll launch the Origami app right here from my Mac.

**[00:48:47]** And I can interact with it.

**[00:48:49]** All the convenience of the simulator with the fidelity of real hardware

**[00:48:54]** in a single place.

**[00:48:56]** That is a quick look at the experience in Xcode 27.

**[00:49:00]** And beyond the experience, the biggest changes this year,

**[00:49:04]** the ones that will truly accelerate you, are in intelligence.

**[00:49:08]** Kevin, over to you.

**[00:49:10]** What a great time to be a developer.

**[00:49:12]** Intelligence is transforming how you build apps.

**[00:49:16]** Agentic coding, together with Apple platforms, frameworks, and tools,

**[00:49:20]** helps you bring ideas to life.

**[00:49:23]** Xcode 27 takes the next big step in agentic coding, leveraging the full power

**[00:49:28]** of the best models and agents directly into Xcode.

**[00:49:32]** Agents are woven into every layer of the Xcode experience,

**[00:49:35]** from the way you interact with them to a set of tools

**[00:49:38]** that help you get the best results.

**[00:49:40]** Tools like understanding your project, searching documentation,

**[00:49:44]** building, and testing.

**[00:49:46]** And Xcode 27 helps you even more with new tools

**[00:49:50]** like rendering previews with variants, interacting with the simulator,

**[00:49:54]** localizing your app, debugging, and more.

**[00:49:57]** And this goes beyond tools.

**[00:49:59]** When using agents in Xcode, every answer is grounded in Swift,

**[00:50:03]** SwiftUI, in Apple frameworks.

**[00:50:06]** That's why, when building for Apple platforms,

**[00:50:09]** Xcode is the best place to code with agents.

**[00:50:12]** Let me show you what this looks like across every stage of app development.

**[00:50:16]** From starting with an idea to implementing and validating it, to improving it,

**[00:50:21]** like adding new languages or fixing issues.

**[00:50:23]** First, I'm gonna add something fun to the Origami app.

**[00:50:27]** My daughter, she loves making origami with me.

**[00:50:30]** I want to surprise her with a feature

**[00:50:31]** that makes up a little choose-your-own-adventure story

**[00:50:34]** about the characters that we make together.

**[00:50:36]** I'll start with a new conversation with the agent.

**[00:50:39]** I'll create one here from the toolbar.

**[00:50:40]** It opens right in the editor, just like any other file.

**[00:50:44]** Here's what I want to build.

**[00:50:46]** In my Origami project,

**[00:50:47]** I want a button that generates a choose-your-own-adventure story

**[00:50:51]** for my daughter.

**[00:50:52]** That alone would get me good results, but I had something a little more specific

**[00:50:56]** in mind, so I'll add some more details.

**[00:50:59]** She'll start by picking some options, like the setting and an item to use

**[00:51:03]** in the story.

**[00:51:05]** The app will generate the first page, and then let her pick what comes next.

**[00:51:09]** I want to use the latest Foundation Models APIs

**[00:51:11]** and present it with beautiful typography.

**[00:51:14]** When using a coding agent, the best results come

**[00:51:17]** from collaborating on the implementation and design first,

**[00:51:20]** before any code is written.

**[00:51:22]** So I'll add /plan to the prompt.

**[00:51:24]** And I'm gonna ask for a diagram while I'm at it.

**[00:51:27]** I find it easier to review the plan that way.

**[00:51:30]** Let's get this started.

**[00:51:31]** The agent is exploring my project using Xcode tools to help it efficiently

**[00:51:36]** understand my code base, its architecture and patterns, to find the best way to

**[00:51:40]** build the feature, and it's asking some clarifying questions.

**[00:51:44]** Do I want to persist it?

**[00:51:45]** Yes. And how many options for the next part of the story?

**[00:51:49]** Two to three is good.

**[00:51:51]** And the agent continues to create the plan.

**[00:51:54]** Let's skip forward in time.

**[00:51:56]** My plan is now ready, and it shows right next to the conversation

**[00:51:59]** in beautifully rendered markdown.

**[00:52:01]** It's very easy to review, and I can also refine it.

**[00:52:05]** Here, the current implementation has a fixed set of settings and items to choose.

**[00:52:09]** I'd love if she could add her own.

**[00:52:12]** I'll add that as a comment.

**[00:52:14]** And now the plan looks good.

**[00:52:16]** Let's kick it off.

**[00:52:18]** Now Xcode and the agent work together to implement the plan.

**[00:52:21]** Xcode shows everything that's changing, like code and previews.

**[00:52:25]** As it runs, I can refine the implementation.

**[00:52:28]** Like here, I'm gonna add a fun image filter to the story's hero image.

**[00:52:33]** It looks like Xcode is done building my feature.

**[00:52:36]** There's still a lot of code, and the previews look great.

**[00:52:39]** Let's just run it.

**[00:52:41]** I'll open an Origami project, tap the new toolbar icon, and just like we asked,

**[00:52:47]** page one offers an item and a setting.

**[00:52:49]** I'll pick a forest and a wand,

**[00:52:52]** and oh look, there's the button if I wanted to add my own.

**[00:52:55]** And here's the first page of the story with that gorgeous hero image.

**[00:53:00]** My daughter's gonna love this.

**[00:53:02]** What was just an idea a couple minutes ago is now something I can run in my app.

**[00:53:06]** This is amazing!

**[00:53:07]** Now, building a feature is more than writing code.

**[00:53:10]** It's also making sure it does what it's supposed to do.

**[00:53:14]** Xcode 27 can help you with that too, with new tools for agents to check their work.

**[00:53:19]** For example, agents can validate the logic of your app by running tests,

**[00:53:23]** try ideas in isolation using playgrounds, like experimenting with APIs,

**[00:53:28]** and check visual changes with Previews in light and dark mode,

**[00:53:32]** different orientations, text sizes, or localizations.

**[00:53:37]** And now agents can interact with your app in the simulator.

**[00:53:41]** Let me show you.

**[00:53:42]** I want to test different combinations of settings, items, even customized ones.

**[00:53:48]** Xcode launches Origami and Device Hub and starts testing those for me.

**[00:53:52]** The agent can tap, swipe, and type.

**[00:53:56]** When it's done, I get a summary of the tests, and I can see all the screenshots

**[00:54:01]** it created along the way.

**[00:54:03]** And just like that, the Origami app has a new story feature, designed, built,

**[00:54:09]** and tested end-to-end.

**[00:54:11]** Next, let's see how we can use agentic coding to improve our app.

**[00:54:16]** Agents in Xcode can help with all kinds of engineering tasks, like adopting new APIs,

**[00:54:22]** making your app more accessible, and more.

**[00:54:24]** Let's localize our Origami app.

**[00:54:26]** I'll start with French.

**[00:54:29]** Xcode automatically adds a new language to the strings catalog,

**[00:54:33]** then works with the agents to translate strings

**[00:54:35]** across the entire project.

**[00:54:37]** This is more than a word-for-word translation.

**[00:54:40]** Xcode looks at each string in its context, the surrounding code, UI, the action,

**[00:54:45]** to find the best translation.

**[00:54:47]** And when it's done, I can see all the translations here in the String Catalog.

**[00:54:52]** Let's build and run.

**[00:54:54]** My app is now localized!

**[00:54:56]** Fantastique!

**[00:54:58]** Building a great app also means responding to the feedback and data from your users.

**[00:55:03]** The Organizer already gives you insights into how your app is doing

**[00:55:07]** in the real world - crashes, hangs, performance metrics,

**[00:55:11]** anonymized and aggregated.

**[00:55:13]** Now, you can use agents to help you find issues that matter most, and fix them.

**[00:55:19]** I'll ask Xcode to pull up the top crashes from the latest release.

**[00:55:23]** I get a list of crashes ranked by how often they happen.

**[00:55:26]** Oh, that first one is from an update I pushed last week.

**[00:55:29]** Let's fix it.

**[00:55:33]** Xcode looks at the symbolicated crash log, figures out where in my project

**[00:55:38]** this happens, identifies the issue, reproduces the crash, makes the fix,

**[00:55:44]** and then validates it.

**[00:55:47]** And just like that, our issue is fixed.

**[00:55:50]** That's agents at work with Xcode across every stage of your development, planning,

**[00:55:55]** building, and improving.

**[00:55:57]** You'll be amazed when you see Xcode and agents bring your ideas to life.

**[00:56:02]** Finally, let's talk about what makes all of this possible.

**[00:56:05]** Xcode 27 ships with the expertise of Apple's engineers and designers

**[00:56:09]** built right in as a corpus of skills, documentation, and MCP tools.

**[00:56:14]** Think of them as specialists.

**[00:56:16]** A SwiftUI specialist that knows how to structure your view and data flow.

**[00:56:21]** An accessibility specialist that knows what makes an interface work for everyone.

**[00:56:25]** Specialists for universal sizing, testing, and performance.

**[00:56:30]** In fact, so much of what we've seen to this point

**[00:56:32]** is powered by one of these specialists.

**[00:56:34]** And you can bring your own!

**[00:56:37]** Xcode integrates all of them in the same way.

**[00:56:40]** Plugins.

**[00:56:41]** It's a format used by many agents and widely adopted by the community.

**[00:56:45]** It's amazing to see how many of these you have already been building and sharing.

**[00:56:50]** A plugin can contain skills, just markdown files that teach the agent new tasks.

**[00:56:56]** It can contain tools using the Model Context Protocol.

**[00:57:00]** And we've added one new capability to plugins.

**[00:57:03]** With the Agent Client Protocol, a plugin can bring an agent of your choice.

**[00:57:08]** Installing one is easy.

**[00:57:09]** You can use the command line or paste a git URL right into Xcode.

**[00:57:13]** And partners like Figma and GitHub make it even easier to set up with just one click.

**[00:57:19]** And then I can put it all together.

**[00:57:22]** I can tell Xcode to implement a Figma design in SwiftUI, refine it for different

**[00:57:26]** variants, make it resizable using a skill, and post a PR to GitHub.

**[00:57:31]** How cool is that?

**[00:57:33]** That's Agentic Coding in Xcode 27.

**[00:57:36]** From an idea to an app, at every step.

**[00:57:40]** Built for how you create, refine, and ship, and reach your users

**[00:57:44]** wherever they are.

**[00:57:45]** We can't wait to see what great things you make next!

**[00:57:49]** Back to you, Josh.

**[00:57:52]** It's a huge year for Xcode and for many of our other developer tools as well.

**[00:57:57]** Like the all-new Reality Composer Pro 3, which has been completely rebuilt for

**[00:58:03]** crafting production-ready 3D experiences using RealityKit.

**[00:58:08]** It brings support for character animations, more realistic lighting,

**[00:58:12]** and live previews that let you see the results of your edits

**[00:58:15]** as you make them using Mac Virtual Display.

**[00:58:19]** And there's even more for game developers in this year's releases,

**[00:58:22]** including a major update to Game Porting Toolkit,

**[00:58:25]** which dramatically cuts the time it takes to bring games

**[00:58:28]** to Apple platforms by adding AI skills for coding agents.

**[00:58:33]** And new Metal command line tools give agents direct control

**[00:58:37]** during development and debugging, bringing best practices

**[00:58:40]** for game development on Apple platforms to every step of your porting journey.

**[00:58:46]** So that's developer productivity.

**[00:58:48]** Across the 2027 releases, there are so many new capabilities to build on,

**[00:58:54]** like the App Intents framework, which lets you connect your app

**[00:58:57]** to Apple Intelligence, and the Foundation Models framework

**[00:59:01]** and Core AI, which enable you to bring

**[00:59:03]** powerful generative intelligence features directly into your apps.

**[00:59:08]** There are platform improvements across design, Swift, and SwiftUI

**[00:59:13]** that make your apps faster, more flexible, and easier to build.

**[00:59:18]** And Xcode has even more expansive support for agentic coding.

**[00:59:23]** and we've only just scratched the surface.

**[00:59:25]** There are over 100 sessions to dive deep into everything we've covered today,

**[00:59:31]** including Apple Intelligence, Xcode 27, Design, and more.

**[00:59:37]** All these sessions are available on the Apple Developer app, the website, YouTube,

**[00:59:42]** and new this year on Bilibili.

**[00:59:45]** And there's so much more happening online throughout the week.

**[00:59:49]** Sign up for Group Labs, online panels, and Q sessions

**[00:59:53]** with Apple engineers and designers.

**[00:59:56]** And connect with us on the Apple Developer Forums

**[00:59:58]** to ask questions, and follow the conversation

**[01:00:01]** about the latest tools and technologies.

**[01:00:04]** And the opportunities to connect extend well beyond this week.

**[01:00:08]** You can Meet with Apple around the world and online in hands-on workshops, labs,

**[01:00:14]** and events to learn and connect as a community throughout the year.

**[01:00:20]** We love when we can meet you in person.

**[01:00:23]** And there are many opportunities to do that in our Developer Centers,

**[01:00:27]** located in Cupertino, Shanghai, Singapore, and Bengaluru.

**[01:00:32]** And we're excited to announce the opening of our fifth this fall in Berlin,

**[01:00:38]** home to one of Europe's most vibrant developer and designer communities.

**[01:00:42]** We can't wait to see you there or in one of our events online.

**[01:00:47]** Whether this is your first WWDC or your 25th, thank you.

**[01:00:53]** Your work inspires and drives us.

**[01:00:56]** We use the apps and play the games that you all build.

**[01:01:00]** So, our greatest hope is that everything we talked about today

**[01:01:04]** will enable your next great idea to come to life.

**[01:01:09]** We can't wait to see what you do next.

**[01:01:11]** Enjoy WWDC.
