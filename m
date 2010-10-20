From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: cgroup debug seems dead?
Date: Wed, 20 Oct 2010 09:11:10 +0800
Message-ID: <4CBE41AE.2020101@cn.fujitsu.com>
References: <20101019085139.1ccb22bc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101019085139.1ccb22bc@nehalam>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Stephen Hemminger wrote:
> While running namespace checks to look for dead code,
> I found that debug_subsys is declared global but never
> used in current code.
> 
> This leads to the fact that since debug_subsys is never
> used, the whole set of debugging functions is also never
> used.  Is the whole CGROUP_DEBUG config option dead?
> 

No, it's not.

The debug code has been moved from kernel/cgroup_debug.c to
kernel/cgroup.c, but the config and the code is not dead.

Is it a false positive of that check? The pointer to debug_subsys
is stored in an array, and the array will be iterated in some places,
so debug_subsys will be accessed.
