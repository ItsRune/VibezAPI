"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[81],{3905:(e,t,r)=>{r.d(t,{Zo:()=>p,kt:()=>m});var n=r(67294);function o(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function i(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function a(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?i(Object(r),!0).forEach((function(t){o(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):i(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function s(e,t){if(null==e)return{};var r,n,o=function(e,t){if(null==e)return{};var r,n,o={},i=Object.keys(e);for(n=0;n<i.length;n++)r=i[n],t.indexOf(r)>=0||(o[r]=e[r]);return o}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(n=0;n<i.length;n++)r=i[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(o[r]=e[r])}return o}var l=n.createContext({}),c=function(e){var t=n.useContext(l),r=t;return e&&(r="function"==typeof e?e(t):a(a({},t),e)),r},p=function(e){var t=c(e.components);return n.createElement(l.Provider,{value:t},e.children)},u="mdxType",f={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},d=n.forwardRef((function(e,t){var r=e.components,o=e.mdxType,i=e.originalType,l=e.parentName,p=s(e,["components","mdxType","originalType","parentName"]),u=c(r),d=o,m=u["".concat(l,".").concat(d)]||u[d]||f[d]||i;return r?n.createElement(m,a(a({ref:t},p),{},{components:r})):n.createElement(m,a({ref:t},p))}));function m(e,t){var r=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var i=r.length,a=new Array(i);a[0]=d;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s[u]="string"==typeof e?e:o,a[1]=s;for(var c=2;c<i;c++)a[c]=r[c];return n.createElement.apply(null,a)}return n.createElement.apply(null,r)}d.displayName="MDXCreateElement"},41518:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>l,contentTitle:()=>a,default:()=>f,frontMatter:()=>i,metadata:()=>s,toc:()=>c});var n=r(87462),o=(r(67294),r(3905));const i={"sidebar-position":11},a=void 0,s={unversionedId:"Examples/Nitro Boosters",id:"Examples/Nitro Boosters",title:"Nitro Boosters",description:"Check if a player is a nitro booster",source:"@site/docs/Examples/Nitro Boosters.md",sourceDirName:"Examples",slug:"/Examples/Nitro Boosters",permalink:"/VibezAPI/docs/Examples/Nitro Boosters",draft:!1,editUrl:"https://github.com/ItsRune/VibezAPI/edit/master/docs/Examples/Nitro Boosters.md",tags:[],version:"current",frontMatter:{"sidebar-position":11},sidebar:"defaultSidebar",previous:{title:"Activity",permalink:"/VibezAPI/docs/Examples/Activity"},next:{title:"Ranking",permalink:"/VibezAPI/docs/Examples/Ranking"}},l={},c=[{value:"Check if a player is a nitro booster",id:"check-if-a-player-is-a-nitro-booster",level:3}],p={toc:c},u="wrapper";function f(e){let{components:t,...r}=e;return(0,o.kt)(u,(0,n.Z)({},p,r,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h3",{id:"check-if-a-player-is-a-nitro-booster"},"Check if a player is a nitro booster"),(0,o.kt)("p",null,"Where is this useful? You can use this to give nitro boosters special perks in your game."),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},'local Vibez = require(14946453963)("API Key"):waitUntilLoaded()\n\nlocal function onPlayerAdded(Player: Player)\n    local isBooster = Vibez:isBooster(Player.UserId)\n\n    if isBooster then\n        warn(string.format("%s is a nitro booster!", Player.Name))\n    end\nend\n')))}f.isMDXComponent=!0}}]);