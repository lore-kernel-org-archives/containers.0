From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 2.6.24-rc3-mm1] IPC: make struct ipc_ids static in ipc_namespace
Date: Fri, 23 Nov 2007 14:06:49 +0300
Message-ID: <4746B449.5010204@openvz.org>
References: <20071122155448.3193c856.pierre.peiffer@bull.net> <474680B5.7020104@fr.ibm.com> <47468347.5090303@openvz.org> <47468927.3040304@openvz.org> <47469630.3060807@bull.net> <47469CF3.1030200@openvz.org> <4746B027.4020506@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756645AbXKWLIZ@vger.kernel.org>
In-Reply-To: <4746B027.4020506@bull.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Pierre Peiffer <pierre.peiffer@bull.net>
Cc: Cedric Le Goater <clg@fr.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Pierre Peiffer wrote:
> Ok, I have the patch ready, but before sending it, I worry about the size of
> struct ipc_namespace if we mark struct ipc_ids as ___cacheline_aligned....
> 
> Of course, you we fall into a classical match: performance vs memory size.
> 
> As I don't think that I have the knowledge to decide what we must focus on, here
> after is, for info, the size reported by pahole (on x86, Intel Xeon)
> 
> With the patch sent at the beginning of this thread we have:
> 
> struct ipc_namespace {
>         struct kref                kref;                 /*     0     4 */
>         struct ipc_ids             ids[3];               /*     4   156 */
>         /* --- cacheline 2 boundary (128 bytes) was 32 bytes ago --- */
>         int                        sem_ctls[4];          /*   160    16 */
>         int                        used_sems;            /*   176     4 */
>         int                        msg_ctlmax;           /*   180     4 */
>         int                        msg_ctlmnb;           /*   184     4 */
>         int                        msg_ctlmni;           /*   188     4 */
>         /* --- cacheline 3 boundary (192 bytes) --- */
>         atomic_t                   msg_bytes;            /*   192     4 */
>         atomic_t                   msg_hdrs;             /*   196     4 */

cacheline boundary is to be here as well... But anyway, please, see my
last comment :)

>         size_t                     shm_ctlmax;           /*   200     4 */
>         size_t                     shm_ctlall;           /*   204     4 */
>         int                        shm_ctlmni;           /*   208     4 */
>         int                        shm_tot;              /*   212     4 */
> 
>         /* size: 216, cachelines: 4 */
>         /* last cacheline: 24 bytes */
> };      /* definitions: 1 */
> 
> With the new patch, if we mark the struct ipc_ids as ____cacheline_aligned, we
> have (I put kref at the end, to save one more cacheline):
> 
> struct ipc_namespace {
>         struct ipc_ids             sem_ids;              /*     0    64 */
> 
>         /* XXX last struct has 12 bytes of padding */
> 
>         /* --- cacheline 1 boundary (64 bytes) --- */
>         int                        sem_ctls[4];          /*    64    16 */
>         int                        used_sems;            /*    80     4 */
> 
>         /* XXX 44 bytes hole, try to pack */
> 
>         /* --- cacheline 2 boundary (128 bytes) --- */
>         struct ipc_ids             msg_ids;              /*   128    64 */
> 
>         /* XXX last struct has 12 bytes of padding */
> 
>         /* --- cacheline 3 boundary (192 bytes) --- */
>         int                        msg_ctlmax;           /*   192     4 */
>         int                        msg_ctlmnb;           /*   196     4 */
>         int                        msg_ctlmni;           /*   200     4 */
>         atomic_t                   msg_bytes;            /*   204     4 */
>         atomic_t                   msg_hdrs;             /*   208     4 */
> 
>         /* XXX 44 bytes hole, try to pack */
> 
>         /* --- cacheline 4 boundary (256 bytes) --- */
>         struct ipc_ids             shm_ids;              /*   256    64 */
> 
>         /* XXX last struct has 12 bytes of padding */
> 
>         /* --- cacheline 5 boundary (320 bytes) --- */
>         size_t                     shm_ctlmax;           /*   320     4 */
>         size_t                     shm_ctlall;           /*   324     4 */
>         int                        shm_ctlmni;           /*   328     4 */
>         int                        shm_tot;              /*   332     4 */
>         struct kref                kref;                 /*   336     4 */
> 
>         /* size: 384, cachelines: 6 */
>         /* sum members: 252, holes: 2, sum holes: 88 */
>         /* padding: 44 */
>         /* paddings: 3, sum paddings: 36 */
> };      /* definitions: 1 */
> 
> We can put all sysctl related values together, in one cacheline and keep ipc_ids
> cacheline aligned ? But I really wonder about the performance gain here...

Well I think you're right. The structure gains 50% in size... Really too
much to fight for performance in IPC :)

Thanks for checking this thing.

You may put my Acked-by in the original patch.

Thanks,
Pavel
