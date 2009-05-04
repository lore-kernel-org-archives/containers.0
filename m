From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/7] Have alloc_pidmap() return actual error code
Date: Mon, 4 May 2009 11:29:54 -0700
Message-ID: <20090504182954.GB31892@linux.vnet.ibm.com>
References: <12414250653025-git-send-email-sukadev@linux.vnet.ibm.com>
	<1241425065670-git-send-email-sukadev@linux.vnet.ibm.com>
	<20090504181111.GM11734@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090504181111.GM11734-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Matt Helsley [matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > @@ -159,8 +160,10 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
| >  	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
| >  	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
| >  	for (i = 0; i <= max_scan; ++i) {
| > -		if (alloc_pidmap_page(map))
| > +		if (alloc_pidmap_page(map)) {
| > +			rc = -ENOMEM;
| 
| You could return -ENOMEM from alloc_pidmap_page(map) and then just:
| 
| 	rc = alloc_pidmap_page(map);
| 	if (rc)
| 		break;

Sure. alloc_pidmap_page() can only fail for one reason so I let it stay,
but we might as well return -ENOMEM.
