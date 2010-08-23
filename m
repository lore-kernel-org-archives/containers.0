From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: Containers vs. OpenVZ
Date: Mon, 23 Aug 2010 11:44:42 +0400
Message-ID: <4C7226EA.5020600@parallels.com>
References: <20100817103339.GA8495@nibiru.local>
	<20100818002416.GG3648@count0.beaverton.ibm.com>
	<4C6B3082.2070802@cs.columbia.edu>
	<AANLkTinLMVV21pW_icDriWbrZ1U8NgfKYWMhFLBD5XS-@mail.gmail.com>
	<20100818170256.GA3642@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100818170256.GA3642-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Marc Aymerich <glicerinu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
List-Id: containers.vger.kernel.org

> Marc,
> 
> 	We are quite aware of and appreciate openvz's many kernel
> contributions. Please consider the context of Oren's reply above. I was
> talking about checkpoint/restart not being in the mainline kernel. I
> am not aware of any openvz checkpoint/restart code in the mainline
> kernel. [ Cc'ing Pavel so he can correct me if I am wrong. ]

No we don't have any our cpt/rst code in the mainline unfortunately :(
And no - you cannot replace openvz with lxc yet for many reasons.

> Cheers,
> 	-Matt Helsley
> 
