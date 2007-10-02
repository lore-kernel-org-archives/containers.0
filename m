From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 5/5] Account for the slub objects
Date: Tue, 2 Oct 2007 11:04:38 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0710021104000.30559@schroedinger.engr.sgi.com>
References: <46F91841.9070708@openvz.org> <46F91A8A.9000001@openvz.org>
	<4700FF1F.7060604@linux.vnet.ibm.com> <4700FFC3.7050005@openvz.org>
	<Pine.LNX.4.64.0710011341000.19779@schroedinger.engr.sgi.com>
	<47023D18.3090304@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47023D18.3090304-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2 Oct 2007, Pavel Emelyanov wrote:

> Christoph Lameter wrote:
> > On Mon, 1 Oct 2007, Pavel Emelyanov wrote:
> > 
> >>>> +
> >>> Quick check, slub_free_notify() and slab_alloc_notify() are called
> >>> from serialized contexts, right?
> >> Yup.
> > 
> > How is it serialized?
> 
> They are booth called from __slab_alloc()/__slab_free() from under 
> the slab_lock(page).

This means they are serialized per slab. Which means you can guarantee 
that multiple of these callbacks are not done at the same time for the 
same object. Is that what you need?
