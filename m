From: sukadev@us.ibm.com
Subject: Re: [PATCH 0/3] clone64() and unshare64() system calls
Date: Wed, 9 Apr 2008 19:38:18 -0700
Message-ID: <20080410023818.GD28477@us.ibm.com>
References: <20080409222611.GA28087@us.ibm.com> <47FD5899.2040206@zytor.com> <20080410010717.GA28477@us.ibm.com> <47FD6921.6090408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756179AbYDJCjr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47FD6921.6090408@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@osdl.org>, clg@fr.ibm.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

H. Peter Anvin [hpa@zytor.com] wrote:
>> Yes, this was discussed before in the context of Pavel Emelyanov's patch
>> 	http://lkml.org/lkml/2008/1/16/109
>> along with sys_indirect().  While there was no consensus, it looked like
>> adding a new system call was better than open ended interfaces.
>
> That's not really an open-ended interface, it's just an expandable bitmap.

Yes, we liked such an approach earlier too and its conceivable that we
will run out of the 64-bits too :-)

But as Jon Corbet pointed out in the the thread above, it looked like
adding a new system call has been the "traditional" way of solving this
in Linux so far and there has been no consensus on a newer approach.

Sukadev
