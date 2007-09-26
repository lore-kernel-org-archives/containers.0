From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 3/5] Switch caches notification dynamically
Date: Wed, 26 Sep 2007 10:30:18 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709261029300.15435@schroedinger.engr.sgi.com>
References: <46F91841.9070708@openvz.org> <46F919BB.2000701@openvz.org>
	<Pine.LNX.4.64.0709251447560.5072@schroedinger.engr.sgi.com>
	<46FA28C9.9060101@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46FA28C9.9060101-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 26 Sep 2007, Pavel Emelyanov wrote:

> > Is it necessary to mark all the existing slabs with SLAB_DEBUG? Would it 
> 
> Yup. Otherwise we can never receive a single event e.g. if we make 
> alloc/free in a loop, or similar, so that new slabs simply are not 
> created.

Right but on the other hand: If objects in these slabs are freed then your 
counters get decremented and may go negative.
