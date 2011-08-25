From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 21:11:50 +0400
Message-ID: <20110825171150.GB6387@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
 <20110825170147.GM2803@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825170147.GM2803@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 07:01:47PM +0200, Tejun Heo wrote:
...
> 
> Hmm... don't we need the same credential update as
> tid_fd_revalidate()?  If the task seteuid's, we want the permissions
> to change accordingly, right?
> 
> Thanks.
>

Exactly! Thanks Tejun. I'll be reworking it anyway (acoording to what
we decide to do with start-end range in names).
 
	Cyrill
