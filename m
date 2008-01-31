From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 0/6] preparations to enable netdevice notifiers inside
 a namespace (resend)
Date: Thu, 31 Jan 2008 18:46:46 +0100
Message-ID: <47A20986.9090701@free.fr>
References: <47A1B835.7050600@sw.ru> <47A1E21C.40909@free.fr> <939d53060801310847y31c4542do271edd48e44745c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <939d53060801310847y31c4542do271edd48e44745c7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
To: Benjamin Thery <ben.thery@gmail.com>
Cc: "Denis V. Lunev" <den@sw.ru>, Linux Containers <containers@lists.osdl.org>, netdev <netdev@vger.kernel.org>
List-Id: containers.vger.kernel.org

Benjamin Thery wrote:
> On Jan 31, 2008 3:58 PM, Daniel Lezcano <daniel.lezcano@free.fr> wrote:
> 
>> Denis V. Lunev wrote:
>>> Here are some preparations and cleanups to enable network device/inet
>>> address notifiers inside a namespace.
>>>
>>> This set of patches has been originally sent last Friday. One cleanup
>>> patch from the original series is dropped as wrong, thanks to Daniel
>>> Lezcano.
>> Can you explain please.
> 
> 
> I think Denis refers to the patch called "3/7 Prohibit assignment of
> 0.0.0.0as interface address." ,
> he dropped because it was inappropriate, no?

Yes, you are right, Denis explained me in a private email. I think I 
really need to sleep a little more :)
