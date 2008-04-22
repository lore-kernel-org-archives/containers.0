From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Checkpoint/restart (was Re: [PATCH 0/4] - v2 -  Object creation
	with a specified id)
Date: Tue, 22 Apr 2008 23:36:12 +0400
Message-ID: <20080422193612.GA15835__39847.4130234264$1208889907$gmane$org@martell.zuzino.mipt.ru>
References: <20080418054459.891481000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080418054459.891481000-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 18, 2008 at 07:44:59AM +0200, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:
>    . echo "LONG XX" > /proc/self/task/<my_tid>/next_id
>      next object to be created will have an id set to XX
>    . echo "LONG<n> X0 ... X<n-1>" > /proc/self/task/<my_tid>/next_id
>      next object to be created will have its ids set to XX0, ... X<n-1>
>      This is particularly useful for processes that may have several ids if
>      they belong to nested namespaces.

Can we answer the following questions before merging this patch:

a) should mainline kernel have checkpoint/restart feature at all
b) if yes, should it be done from kernel- or userspace?

Until agreement will be "yes/from userspace" such patches don't make
sense in mainline.
