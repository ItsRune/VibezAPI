"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[736],{3905:(e,t,l)=>{l.d(t,{Zo:()=>u,kt:()=>b});var a=l(67294);function r(e,t,l){return t in e?Object.defineProperty(e,t,{value:l,enumerable:!0,configurable:!0,writable:!0}):e[t]=l,e}function n(e,t){var l=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),l.push.apply(l,a)}return l}function s(e){for(var t=1;t<arguments.length;t++){var l=null!=arguments[t]?arguments[t]:{};t%2?n(Object(l),!0).forEach((function(t){r(e,t,l[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(l)):n(Object(l)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(l,t))}))}return e}function i(e,t){if(null==e)return{};var l,a,r=function(e,t){if(null==e)return{};var l,a,r={},n=Object.keys(e);for(a=0;a<n.length;a++)l=n[a],t.indexOf(l)>=0||(r[l]=e[l]);return r}(e,t);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);for(a=0;a<n.length;a++)l=n[a],t.indexOf(l)>=0||Object.prototype.propertyIsEnumerable.call(e,l)&&(r[l]=e[l])}return r}var o=a.createContext({}),c=function(e){var t=a.useContext(o),l=t;return e&&(l="function"==typeof e?e(t):s(s({},t),e)),l},u=function(e){var t=c(e.components);return a.createElement(o.Provider,{value:t},e.children)},p="mdxType",k={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},d=a.forwardRef((function(e,t){var l=e.components,r=e.mdxType,n=e.originalType,o=e.parentName,u=i(e,["components","mdxType","originalType","parentName"]),p=c(l),d=r,b=p["".concat(o,".").concat(d)]||p[d]||k[d]||n;return l?a.createElement(b,s(s({ref:t},u),{},{components:l})):a.createElement(b,s({ref:t},u))}));function b(e,t){var l=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var n=l.length,s=new Array(n);s[0]=d;var i={};for(var o in t)hasOwnProperty.call(t,o)&&(i[o]=t[o]);i.originalType=e,i[p]="string"==typeof e?e:r,s[1]=i;for(var c=2;c<n;c++)s[c]=l[c];return a.createElement.apply(null,s)}return a.createElement.apply(null,l)}d.displayName="MDXCreateElement"},92169:(e,t,l)=>{l.r(t),l.d(t,{assets:()=>o,contentTitle:()=>s,default:()=>k,frontMatter:()=>n,metadata:()=>i,toc:()=>c});var a=l(87462),r=(l(67294),l(3905));const n={sidebar_position:4},s=void 0,i={unversionedId:"Features/Blacklists",id:"Features/Blacklists",title:"Blacklists",description:"What does blacklisting do?",source:"@site/docs/Features/Blacklists.md",sourceDirName:"Features",slug:"/Features/Blacklists",permalink:"/VibezAPI/docs/Features/Blacklists",draft:!1,editUrl:"https://github.com/ItsRune/VibezAPI/edit/master/docs/Features/Blacklists.md",tags:[],version:"current",sidebarPosition:4,frontMatter:{sidebar_position:4},sidebar:"defaultSidebar",previous:{title:"Webhooks",permalink:"/VibezAPI/docs/Features/Webhooks"},next:{title:"Notifications",permalink:"/VibezAPI/docs/Features/Notifications"}},o={},c=[{value:"What does blacklisting do?",id:"what-does-blacklisting-do",level:2},{value:"Usage",id:"usage",level:2},{value:"addBlacklist",id:"addblacklist",level:3},{value:"deleteBlacklist",id:"deleteblacklist",level:3},{value:"isUserBlacklisted",id:"isuserblacklisted",level:3},{value:"getBlacklists",id:"getblacklists",level:3}],u={toc:c},p="wrapper";function k(e){let{components:t,...l}=e;return(0,r.kt)(p,(0,a.Z)({},u,l,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h2",{id:"what-does-blacklisting-do"},"What does blacklisting do?"),(0,r.kt)("p",null,"Blacklisting a user will prevent them from doing anything that uses your API key. This includes the usage of our application center and ranking center. This is useful in case you have a user that is causing havoc in your games. Think of this as a ban system attached to your API key."),(0,r.kt)("h2",{id:"usage"},"Usage"),(0,r.kt)("h3",{id:"addblacklist"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#addBlacklist"},"addBlacklist")),(0,r.kt)("p",null,"Adds a new blacklist."),(0,r.kt)("p",null,"Parameter(s): ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"userId: number")," - The user id of the player you want to blacklist. ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"reason: string?")," - The reason for blacklisting the user. ",(0,r.kt)("strong",{parentName:"p"},"OPTIONAL"),(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"blacklistedBy: number?")," - The user id of the person who blacklisted the user. ",(0,r.kt)("strong",{parentName:"p"},"OPTIONAL"),(0,r.kt)("br",null)),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#blacklistResponse"},"blacklistResponse")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local userId = 107392833\nlocal reason = "Spamming the group wall."\nlocal userWhoBlacklisted = 1 -- ROBLOX\nVibezApi:addBlacklist(userId, userWhoBlacklisted)\n')),(0,r.kt)("h3",{id:"deleteblacklist"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#deleteBlacklist"},"deleteBlacklist")),(0,r.kt)("p",null,"Removes a blacklist."),(0,r.kt)("p",null,"Parameter(s): ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"userId: number")," - The user id of the player you want to remove the blacklist of. ",(0,r.kt)("br",null)),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#blacklistResponse"},"blacklistResponse")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local userId = 107392833\nVibezApi:deleteBlacklist(userId)\n")),(0,r.kt)("h3",{id:"isuserblacklisted"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#isUserBlacklisted"},"isUserBlacklisted")),(0,r.kt)("p",null,"Checks if a user is blacklisted."),(0,r.kt)("p",null,"Parameter(s): ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"userId: number")," - The user id of the player you want to check if they're blacklisted. ",(0,r.kt)("br",null)),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#isUserBlacklisted"},"(boolean, string?)")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local userId = 107392833\nlocal isBlacklisted, blacklistReason, blacklistedBy = VibezApi:isUserBlacklisted(userId)\n")),(0,r.kt)("h3",{id:"getblacklists"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#getBlacklists"},"getBlacklists")),(0,r.kt)("p",null,"Gets all blacklists."),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#fullBlacklists"},"fullBlacklists")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local blacklists = VibezApi:getBlacklists()\n")))}k.isMDXComponent=!0}}]);