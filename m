From: Stephan Peijnik <stephan@peijnik.at>
Subject: Re: LSM stacking/secondary modules / RFC: Socket MAC LSM
Date: Thu, 15 Jan 2009 18:58:08 +0100
Message-ID: <1232042288.30029.25.camel@sp-laptop3.sp-local>
References: <1231952352.5315.13.camel@sp-laptop3.sp-local>
	 <1231953606.31192.41.camel@localhost.localdomain>
	 <f639a5c10901140934w3a019308yb5c5c1d73b605fd5@mail.gmail.com>
	 <20090114180129.GB7337@kroah.com>
	 <1231972131.5315.48.camel@sp-laptop3.sp-local>
	 <20090114231645.GA24111@kroah.com>
	 <1231979170.5315.69.camel@sp-laptop3.sp-local>
	 <20090115004143.GB14467@us.ibm.com> <20090115004407.GA14867@us.ibm.com>
	 <1232027832.14136.8.camel@sp-laptop3.sp-local>
	 <6599ad830901150925p771dcc3if60b8ec5ed617963@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <6599ad830901150925p771dcc3if60b8ec5ed617963@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Greg KH <greg@kroah.com>, Rafael Konrath <rafael.konrath@gmail.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>, Grzegorz Nosek <root@localdomain.pl>
List-Id: containers.vger.kernel.org

On Thu, 2009-01-15 at 09:25 -0800, Paul Menage wrote:
> On Thu, Jan 15, 2009 at 5:57 AM, Stephan Peijnik <stephan@peijnik.at> wrote:
> >
> > So Paul, do you think the interface would be of any use to you?
> 
> Potentially, yes. My concern was that we not add another new
> (incomplete) userspace API in cgroups for doing socket permissions -
> hooking into iptables was one way to do it, but if sactl is going to
> become the official way to do this, then hooking a cgroups filter into
> that seems like a good alternative.

Just to clarify that: sactl is my pet project and inclusion in
linux-next (or whenever) has not been discussed yet, but if enough
potential users pop up I would love try getting it included.

I rather meant to ask if this interface could be of any use to you (and
others) and whether you would want/need any modifications to it, if
there are any flaws in its design, bugs in the code, etc.

-- Stephan

