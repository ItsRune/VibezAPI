"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[465],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>h});var a=n(67294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function o(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?o(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,a,r=function(e,t){if(null==e)return{};var n,a,r={},o=Object.keys(e);for(a=0;a<o.length;a++)n=o[a],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(a=0;a<o.length;a++)n=o[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var c=a.createContext({}),s=function(e){var t=a.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},p=function(e){var t=s(e.components);return a.createElement(c.Provider,{value:t},e.children)},m="mdxType",d={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},u=a.forwardRef((function(e,t){var n=e.components,r=e.mdxType,o=e.originalType,c=e.parentName,p=l(e,["components","mdxType","originalType","parentName"]),m=s(n),u=r,h=m["".concat(c,".").concat(u)]||m[u]||d[u]||o;return n?a.createElement(h,i(i({ref:t},p),{},{components:n})):a.createElement(h,i({ref:t},p))}));function h(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var o=n.length,i=new Array(o);i[0]=u;var l={};for(var c in t)hasOwnProperty.call(t,c)&&(l[c]=t[c]);l.originalType=e,l[m]="string"==typeof e?e:r,i[1]=l;for(var s=2;s<o;s++)i[s]=n[s];return a.createElement.apply(null,i)}return a.createElement.apply(null,n)}u.displayName="MDXCreateElement"},70304:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>i,default:()=>d,frontMatter:()=>o,metadata:()=>l,toc:()=>s});var a=n(87462),r=(n(67294),n(3905));const o={sidebar_position:3},i=void 0,l={unversionedId:"Chainable",id:"Chainable",title:"Chainable",description:"What is chainable?",source:"@site/docs/Chainable.md",sourceDirName:".",slug:"/Chainable",permalink:"/VibezAPI/docs/Chainable",draft:!1,editUrl:"https://github.com/ItsRune/VibezAPI/edit/master/docs/Chainable.md",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"defaultSidebar",previous:{title:"Command Operation Codes",permalink:"/VibezAPI/docs/Command Operation Codes"}},c={},s=[{value:"What is chainable?",id:"what-is-chainable",level:3},{value:"How does it work?",id:"how-does-it-work",level:3},{value:"How do I know if a method is chainable?",id:"how-do-i-know-if-a-method-is-chainable",level:3}],p={toc:s},m="wrapper";function d(e){let{components:t,...n}=e;return(0,r.kt)(m,(0,a.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h3",{id:"what-is-chainable"},"What is chainable?"),(0,r.kt)("p",null,"Chainablility is a feature that allows you to chain methods together. For example, instead of doing this:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local VibezAPI = require(script.VibezAPI)("myApiKey")\n\nVibezAPI:removeCommandOperation("Team")\nVibezAPI:removeCommandOperation("Rank")\n')),(0,r.kt)("p",null,"You can do this:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local VibezAPI = require(script.VibezAPI)("myApiKey")\n\nVibezAPI:removeCommandOperation("Team"):removeCommandOperation("Rank")\n')),(0,r.kt)("p",null,"Which not only saves lines but also makes it easier to read, by preventing your eyes from jumping to different lines."),(0,r.kt)("hr",null),(0,r.kt)("h3",{id:"how-does-it-work"},"How does it work?"),(0,r.kt)("p",null,"Chainability works by returning the class instance after every method call. This allows you to call another method on the class instance without having to create a new variable. For example, if you wanted to remove an operation code then immediately promote someone, you could do this:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local VibezAPI = require(script.VibezAPI)("myApiKey")\nlocal playerToRank = game.Players:GetPlayers()[1]\n\nVibezAPI:removeCommandOperation("Team"):SetRank(playerToRank, 1)\n')),(0,r.kt)("hr",null),(0,r.kt)("h3",{id:"how-do-i-know-if-a-method-is-chainable"},"How do I know if a method is chainable?"),(0,r.kt)("p",null,"If a method is chainable, it will be marked with a ",(0,r.kt)("inlineCode",{parentName:"p"},"Chainable")," tag in the documentation. For example, the ",(0,r.kt)("inlineCode",{parentName:"p"},":removeCommandOperation")," method is chainable, so it will be marked with a ",(0,r.kt)("inlineCode",{parentName:"p"},"Chainable")," tag in the documentation."))}d.isMDXComponent=!0}}]);