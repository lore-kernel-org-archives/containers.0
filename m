From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint restart
Date: Mon, 27 Oct 2008 15:09:33 -0700
Message-ID: <1225145373.12673.125.camel__44646.8929796994$1225145523$gmane$org@nimitz>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	<1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>
	<20081021124130.a002e838.akpm@linux-foundation.org>
	<20081021202410.GA10423@us.ibm.com>	<48FE82DF.6030005@cs.columbia.edu>
	<20081022152804.GA23821@us.ibm.com>	<48FF4EB2.5060206@cs.columbia.edu>
	<87tzayh27r.wl%peter@chubb.wattle.id.au>
	<49059FED.4030202@cs.columbia.edu>
	<1225125752.12673.79.camel@nimitz> <4905F648.4030402@cs.columbia.edu>
	<1225140705.5115.40.camel@enoch> <490637D8.4080404@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <490637D8.4080404-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2008-10-27 at 17:51 -0400, Oren Laadan wrote:
> >       Instead, how about a flag to sys_checkpoint() -- DO_RISKY_CHECKPOINT --
> > which checkpoints despite !may_checkpoint?
> 
> I also agree with Matt - so we have a quorum :)
> 
> so just to clarify: sys_checkpoint() is to fail (with what error ?) if the
> deny-checkpoint test fails.
> 
> however, if the user is risky, she can specify CR_CHECKPOINT_RISKY to force
> an attempt to checkpoint as is.

This sounds like an awful lot of policy to determine *inside* the
kernel.  Everybody is going to have a different definition of risky, so
this scheme will work for approximately 5 minutes until it gets
patched. :)

Is it possible to enhance our interface such that users might have some
kind of choice on these matters?

-- Dave
