From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/6] Relink unlinked files for checkpoint/restart support
Date: Mon, 01 Nov 2010 12:38:23 -0400
Message-ID: <4CCEECFF.9010909@cs.columbia.edu>
References: <1285278812-16972-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285278812-16972-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Matt,

This is v2, right ?
If so, is there a changelog ?

Oren.

On 09/23/2010 05:53 PM, Matt Helsley wrote:
> This series enables the relinking of unlinked files for the purpose of
> enabling checkpoint/restart of tasks with open unlinked files. It
> relies on Namhyung Kim's sys-wrapper patches to provide unlink and
> rmdir calls for sys_restart.
> 
> There are two patches with long descriptions. Patch 3 describes
> what we want from the VFS -- relinking support -- and uses ext3/4 as an
> example of what kinds of changes that entails. Patch 5 then details
> how we intend to use relinking during checkpoint to enable restart
> of tasks that have unlinked files open.
> 
> Applies to Oren's ckpt-v22-dev branch. I chose Oren's tree because
> I assume people want to see code showing how relinking will be used.
> If this is wrong I'll be happy to respin these patches against a
> more recent branch of mainline.
> 
> Cheers,
> 	-Matt Helsley
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
