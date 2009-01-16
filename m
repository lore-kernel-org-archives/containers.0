From: Paul Moore <paul.moore@hp.com>
Subject: Re: LSM stacking/secondary modules / RFC: Socket MAC LSM
Date: Fri, 16 Jan 2009 15:43:29 -0500
Message-ID: <200901161543.29320.paul.moore@hp.com>
References: <1231952352.5315.13.camel@sp-laptop3.sp-local> <1232027832.14136.8.camel@sp-laptop3.sp-local> <6599ad830901150925p771dcc3if60b8ec5ed617963@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <6599ad830901150925p771dcc3if60b8ec5ed617963@mail.gmail.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Stephan Peijnik <stephan@peijnik.at>, "Serge E. Hallyn" <serue@us.ibm.com>, Greg KH <greg@kroah.com>, Rafael Konrath <rafael.konrath@gmail.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>, Grzegorz Nosek <root@localdomain.pl>
List-Id: containers.vger.kernel.org

On Thursday 15 January 2009 12:25:34 pm Paul Menage wrote:
> On Thu, Jan 15, 2009 at 5:57 AM, Stephan Peijnik <stephan@peijnik.at> 
wrote:
> > So Paul, do you think the interface would be of any use to you?
>
> Potentially, yes. My concern was that we not add another new
> (incomplete) userspace API in cgroups for doing socket permissions -
> hooking into iptables was one way to do it, but if sactl is going to
> become the official way to do this, then hooking a cgroups filter
> into that seems like a good alternative.

I'll confess to knowing very little about cgroups and even less about 
Stephan's sactl concept (only what I've read so far in this thread), 
however, like Paul Menage I tend to prefer solutions which leverage 
existing mechanisms as much as possible.

Conceptually, I've always associated iptables/netfilter as more of a 
per-packet traffic control mechanism whereas the LSM approach was 
geared more towards per-connection and per-application traffic control 
mechanism; although I will be the first to admit this is a very fuzzy 
distinction and could easily be argued the other way as well.  Other 
than the issues around blocking due to userspace notification and 
potential conflicts with other LSMs are there any objections to using 
the LSM interface?

I know I've come out against the LSM networking hooks proposed by the 
TOMOYO developers in the past to address the blocking issues, and while 
I still believe this is not the "ideal" solution I recognize that there 
are certain use cases and "personal firewall" projects that could 
benefit from such LSM hooks.  While I stand by my original objections, 
I'm most interested in making sure that if we do decide to go forward 
with introducing such functionality into the mainline kernel that we do 
so in the most appropriate manner.

-- 
paul moore
linux @ hp
