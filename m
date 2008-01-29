From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc8-mm1 09/15] (RFC) IPC: new kernel API to
	change an ID
Date: Wed, 30 Jan 2008 00:06:56 +0300
Message-ID: <20080129210656.GB1990__7922.70806055075$1201640947$gmane$org@martell.zuzino.mipt.ru>
References: <20080129160229.612172683@bull.net>
	<20080129162000.454857358@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080129162000.454857358-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: pierre.peiffer-6ktuUTfB/bM@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jan 29, 2008 at 05:02:38PM +0100, pierre.peiffer-6ktuUTfB/bM@public.gmane.org wrote:
> This patch provides three new API to change the ID of an existing
> System V IPCs.
> 
> These APIs are:
> 	long msg_chid(struct ipc_namespace *ns, int id, int newid);
> 	long sem_chid(struct ipc_namespace *ns, int id, int newid);
> 	long shm_chid(struct ipc_namespace *ns, int id, int newid);
> 
> They return 0 or an error code in case of failure.
> 
> They may be useful for setting a specific ID for an IPC when preparing
> a restart operation.
> 
> To be successful, the following rules must be respected:
> - the IPC exists (of course...)
> - the new ID must satisfy the ID computation rule.
> - the entry in the idr corresponding to the new ID must be free.

>  ipc/util.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  ipc/util.h          |    1 +
>  8 files changed, 197 insertions(+)

For the record, OpenVZ uses "create with predefined ID" method which
leads to less code. For example, change at the end is all we want from
ipc/util.c .

Also, if ids were A and B at the moment of checkpoint, and during
restart they became B and A you'll get collision in both ways which you
techically can avoid by classic "tmp = A, A = B, B = tmp" but you also
can avoid all other loops just by creating with ID you need.
