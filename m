From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Fri, 08 Aug 2008 10:24:09 -0700
Message-ID: <1218216249.19082.7.camel@nimitz>
References: <20080731135703.GC22403@hawkmoon.kerlabs.com>
	<4891D5C2.8090000@cs.columbia.edu>
	<20080731155856.GH22403@hawkmoon.kerlabs.com>
	<4891E849.1050701@cs.columbia.edu>
	<20080731175058.GI22403@hawkmoon.kerlabs.com>
	<48920EA0.1060608@cs.columbia.edu>
	<20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu> <20080804101608.GA4081@localdomain>
	<4897BCE0.1080508@cs.columbia.edu>
	<1FA56146-7C30-4C36-982D-A50AA8BC8392@evergrid.com>
	<1217953429.10907.27.camel@nimitz>
	<03CE5BD3-E84A-4617-93BC-722ECB846C63@evergrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <03CE5BD3-E84A-4617-93BC-722ECB846C63-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Joseph Ruscio <jruscio-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2008-08-08 at 10:20 -0700, Joseph Ruscio wrote:
> On Aug 5, 2008, at 9:23 AM, Dave Hansen wrote:
> > How would you propose making it modular?

> What about re-using the madvise() interface for this? Adding a flag  
> along the lines of MADV_DONTCHECKPOINT? I could probably work up a  
> patch to Oren's that removes these from the checkpointed ranges if  
> people think that's feasible.

Seems reasonable, but I think it is jumping the gun a little bit.  There
are plenty of features that will get us quicker, more efficient
checkpoints, but let's get *some* checkpointing in the kernel, first. :)

-- Dave
