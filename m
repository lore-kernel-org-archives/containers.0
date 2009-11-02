From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: pidns memory leak
Date: Mon, 2 Nov 2009 14:47:52 -0800
Message-ID: <20091102144752.71fd4a31.akpm@linux-foundation.org>
References: <20091006040526.GA22923@us.ibm.com>
	<4ACAFD6A.3060008@fr.ibm.com>
	<20091008030828.GA18973@us.ibm.com>
	<4ACD9ECC.90508@fr.ibm.com>
	<20091009032928.GA2031@us.ibm.com>
	<4ACF381F.9050808@fr.ibm.com>
	<20091010013235.GA11904@us.ibm.com>
	<4AD2EBC7.2020109@fr.ibm.com>
	<20091014061533.GA23569@us.ibm.com>
	<20091102133326.e3dc51fb.akpm@linux-foundation.org>
	<20091102223818.GA15628@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757215AbZKBWsl@vger.kernel.org>
In-Reply-To: <20091102223818.GA15628@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, andrea@cpushare.com, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Mon, 2 Nov 2009 16:38:18 -0600
"Serge E. Hallyn" <serue@us.ibm.com> wrote:

> > This bug hasn't been fixed yet, has it?
> 
> Well Suka did trace the bug to commit 7766755a2f249e7, and posted a patch
> to revert that, acked by Eric on Oct 20.  Suka, were you going to repost
> that patch?

Ah.  OK.  Thanks.  Found it in the backlog pile.
