"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[275],{3905:(e,t,i)=>{i.d(t,{Zo:()=>u,kt:()=>f});var r=i(67294);function a(e,t,i){return t in e?Object.defineProperty(e,t,{value:i,enumerable:!0,configurable:!0,writable:!0}):e[t]=i,e}function n(e,t){var i=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),i.push.apply(i,r)}return i}function o(e){for(var t=1;t<arguments.length;t++){var i=null!=arguments[t]?arguments[t]:{};t%2?n(Object(i),!0).forEach((function(t){a(e,t,i[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(i)):n(Object(i)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(i,t))}))}return e}function c(e,t){if(null==e)return{};var i,r,a=function(e,t){if(null==e)return{};var i,r,a={},n=Object.keys(e);for(r=0;r<n.length;r++)i=n[r],t.indexOf(i)>=0||(a[i]=e[i]);return a}(e,t);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);for(r=0;r<n.length;r++)i=n[r],t.indexOf(i)>=0||Object.prototype.propertyIsEnumerable.call(e,i)&&(a[i]=e[i])}return a}var s=r.createContext({}),l=function(e){var t=r.useContext(s),i=t;return e&&(i="function"==typeof e?e(t):o(o({},t),e)),i},u=function(e){var t=l(e.components);return r.createElement(s.Provider,{value:t},e.children)},d="mdxType",p={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},y=r.forwardRef((function(e,t){var i=e.components,a=e.mdxType,n=e.originalType,s=e.parentName,u=c(e,["components","mdxType","originalType","parentName"]),d=l(i),y=a,f=d["".concat(s,".").concat(y)]||d[y]||p[y]||n;return i?r.createElement(f,o(o({ref:t},u),{},{components:i})):r.createElement(f,o({ref:t},u))}));function f(e,t){var i=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var n=i.length,o=new Array(n);o[0]=y;var c={};for(var s in t)hasOwnProperty.call(t,s)&&(c[s]=t[s]);c.originalType=e,c[d]="string"==typeof e?e:a,o[1]=c;for(var l=2;l<n;l++)o[l]=i[l];return r.createElement.apply(null,o)}return r.createElement.apply(null,i)}y.displayName="MDXCreateElement"},94050:(e,t,i)=>{i.r(t),i.d(t,{assets:()=>s,contentTitle:()=>o,default:()=>p,frontMatter:()=>n,metadata:()=>c,toc:()=>l});var r=i(87462),a=(i(67294),i(3905));const n={sidebar_position:5},o=void 0,c={unversionedId:"Activity Tracking",id:"Activity Tracking",title:"Activity Tracking",description:"How does the activity tracking work?",source:"@site/docs/Activity Tracking.md",sourceDirName:".",slug:"/Activity Tracking",permalink:"/VibezAPI/docs/Activity Tracking",draft:!1,editUrl:"https://github.com/ItsRune/VibezAPI/edit/master/docs/Activity Tracking.md",tags:[],version:"current",sidebarPosition:5,frontMatter:{sidebar_position:5},sidebar:"defaultSidebar",previous:{title:"Webhooks",permalink:"/VibezAPI/docs/Webhooks"},next:{title:"Blacklists",permalink:"/VibezAPI/docs/Blacklists"}},s={},l=[{value:"How does the activity tracking work?",id:"how-does-the-activity-tracking-work",level:3},{value:"How do I use the activity tracker?",id:"how-do-i-use-the-activity-tracker",level:3},{value:"How do I get the activity of a staff member?",id:"how-do-i-get-the-activity-of-a-staff-member",level:3},{value:"How do I add seconds to a specific player?",id:"how-do-i-add-seconds-to-a-specific-player",level:3}],u={toc:l},d="wrapper";function p(e){let{components:t,...i}=e;return(0,a.kt)(d,(0,r.Z)({},u,i,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h3",{id:"how-does-the-activity-tracking-work"},"How does the activity tracking work?"),(0,a.kt)("p",null,"The activity tracker works by using object orientated programming that creates specific functions to call upon each staff member within the game. This allows for a more efficient way of tracking staff members and their activity. The activity tracker is also able to track the amount of time a staff member has been active for, and the amount of time they have been inactive for. This allows for a more accurate representation of how active a staff member is."),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"NOTE:")," Inactivity is not sent to Vibez API, it is only used for the activity tracker."),(0,a.kt)("h3",{id:"how-do-i-use-the-activity-tracker"},"How do I use the activity tracker?"),(0,a.kt)("p",null,"The activity tracker is very simple to use. All you need to do is require the main module and change an option to ",(0,a.kt)("inlineCode",{parentName:"p"},"true"),"."),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local Vibez = require(14946453963)("API Key", {\n    activityTrackingEnabled = true\n})\n')),(0,a.kt)("p",null,"In addition to this setting is 2 other options: ",(0,a.kt)("inlineCode",{parentName:"p"},"rankToStartTrackingActivityFor")," and ",(0,a.kt)("inlineCode",{parentName:"p"},"toggleTrackingOfAFKActivity")),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("inlineCode",{parentName:"li"},"rankToStartTrackingActivityFor")," is the rank that the activity tracker will start tracking activity for. This is useful if you want to only track activity for a specific rank."),(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("inlineCode",{parentName:"li"},"toggleTrackingOfAFKActivity")," is a boolean that toggles whether or not the activity tracker will automatically pause counting activity for AFK users.")),(0,a.kt)("h3",{id:"how-do-i-get-the-activity-of-a-staff-member"},"How do I get the activity of a staff member?"),(0,a.kt)("p",null,"Getting the activity of a staff member is very simple. All you need to do is call the ",(0,a.kt)("inlineCode",{parentName:"p"},"getActivity")," function on the Vibez object."),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local Vibez = require(14946453963)("API Key", {\n    activityTrackingEnabled = true\n})\n\nlocal activity = Vibez:getActivity(107392833) -- 107392833 is the user id of the staff member\n')),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"TIP:")," If you'd like to get everyone's activity... Don't put a user id in the ",(0,a.kt)("inlineCode",{parentName:"p"},"getActivity")," function."),(0,a.kt)("h3",{id:"how-do-i-add-seconds-to-a-specific-player"},"How do I add seconds to a specific player?"),(0,a.kt)("p",null,"Vibez allows for customization when necessary, if you're writing your own activity tracker you can achieve this with the ",(0,a.kt)("inlineCode",{parentName:"p"},"saveActivity")," method that the wrapper provides."),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local Vibez = require(14946453963)("API Key", {\n    activityTrackingEnabled = true\n})\n\nlocal function addSecondsToPlayer(UserId: number, secondsSpent: number, messagesSent: number)\n    Vibez:saveActivity(UserId, secondsSpent, messagesSent)\nend\n\naddSecondsToPlayer(107392833, 10, 5) -- 107392833 is the user id of the staff member\n')))}p.isMDXComponent=!0}}]);