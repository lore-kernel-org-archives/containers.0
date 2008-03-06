From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [RFC/PATCH] cgroup swap subsystem
Date: Thu, 6 Mar 2008 00:48:18 -0800
Message-ID: <6599ad830803060048sb39735an765a62e6b928657e@mail.gmail.com>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <47CE5AE2.2050303@openvz.org>
	<Pine.LNX.4.64.0803051400000.22243@blonde.site>
	<47CEAAB4.8070208@openvz.org>
	<20080306093324.77c6d7f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47CFA941.4070507@openvz.org>
	<20080306173347.f6c5c84c.kamezawa.hiroyu@jp.fujitsu.com>
	<47CFAD69.6000909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47CFAD69.6000909-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 6, 2008 at 12:38 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>  > Hierarchical res_counter makes sense.
>  > Making it in simple/reasonable style will be our challenge.
>
>  I have this in my TODO list. Since this is not so urgent, then if you
>  don't mind I can prepare the patches next week - after I set the git
>  tree up. This change doesn't seem that big.
>

The change that you're referring to is allowing a cgroup to have a
total memory limit for itself and all its children, and then giving
that cgroup's children separate memory limits within that overall
limit?

Paul
