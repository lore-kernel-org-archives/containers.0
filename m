From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Teach cifs about network namespaces (take 3)
Date: Thu, 13 Jan 2011 14:02:33 -0500
Message-ID: <20110113140233.093cbf03__46687.6963306733$1294945410$gmane$org@barsoom.rdu.redhat.com>
References: <4D2BDE07.40202@parallels.com>
	<20110111071239.GL29064@count0.beaverton.ibm.com>
	<4D2C63B2.6090109@parallels.com> <4D2C9BC6.7000402@parallels.com>
	<20110111163000.04d02a7f@tlielax.poochiereds.net>
	<4D2DB350.1010509@parallels.com> <4D2F4A88.6060601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D2F4A88.6060601-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 13 Jan 2011 12:55:04 -0600
Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> Teach cifs about network namespaces, so mounting uses adresses/routing
> visible from the container rather than from init context.
> 
> Signed-off-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> ---
> 
> Now using net_eq(), with the initialization moved up so the error path doesn't
> dereference a null on the put.
> 
>  fs/cifs/cifsglob.h |   33 +++++++++++++++++++++++++++++++++
>  fs/cifs/connect.c  |   12 ++++++++++--
>  2 files changed, 43 insertions(+), 2 deletions(-)
> 

Looks good to me:

Reviewed-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
