From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][NETNS] release net when pneigh_lookup fails
Date: Tue, 30 Oct 2007 09:35:32 -0700
Message-ID: <1193762132.24087.265.camel@localhost>
References: <47272C3B.5080601@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47272C3B.5080601-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2007-10-30 at 14:06 +0100, Daniel Lezcano wrote:
> 
> Index: linux-2.6-netns/net/core/neighbour.c
> ===================================================================
> --- linux-2.6-netns.orig/net/core/neighbour.c
> +++ linux-2.6-netns/net/core/neighbour.c
> @@ -497,6 +497,7 @@ struct pneigh_entry * pneigh_lookup(stru
>          if (tbl->pconstructor && tbl->pconstructor(n)) {
>                  if (dev)
>                          dev_put(dev);
> +               release_net(n->net);
>                  kfree(n);
>                  n = NULL;
>                  goto out;
> _______________________________________________ 

Looks like there are some tabs vs. spaces issues in there.  You should
probably just make your line match the ones around it.

-- Dave
