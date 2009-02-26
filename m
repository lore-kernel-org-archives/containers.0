From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 4/4] keys: make procfiles per-user-namespace
Date: Wed, 25 Feb 2009 21:39:18 -0600
Message-ID: <20090226033917.GA3826@us.ibm.com>
References: <20090225210336.GA20086@us.ibm.com> <20090223204041.GA31626@us.ibm.com> <20090109225313.GB15599@us.ibm.com> <20090109225208.GA15252@us.ibm.com> <5296.1234522990@redhat.com> <16728.1235565664@redhat.com> <7386.1235606002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757904AbZBZDjb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7386.1235606002@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells@redhat.com):
> Serge E. Hallyn <serue@us.ibm.com> wrote:
> 
> > So you want users to be able to mmap the file and lseek to a particular
> > spot?
> 
> mmap?  *blink*

/me pretends he didn't say that

> > Meanwhile, do you have any objections to these 4 patches?  :)
> 
> Not really.  You can add my Acked-by.

Thanks.

> It's just that mapping fpos to keyid
> might simplify the code.

Ok i think i see what you mean.  I'll give it a shot.

thanks,
-serge
