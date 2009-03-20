From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 17/23] Record 'struct file' object instead
	of the file name for VMAs
Date: Fri, 20 Mar 2009 15:43:47 -0700
Message-ID: <1237589027.8286.340.camel@nimitz>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-18-git-send-email-orenl@cs.columbia.edu>
	<1237582675.8286.281.camel@nimitz> <49C40893.1060602@cs.columbia.edu>
	<1237584650.8286.310.camel@nimitz> <49C41273.5000202@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C41273.5000202-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-03-20 at 18:02 -0400, Oren Laadan wrote:
> Anyway, the down side that I was hoping to avoid on restart, is to need
> to expect "either...or" values of 'struct cr_hdr'->type instead of a
> single deterministic value. That's the extra burden that I was referring
> to.

I think this "determinism" actually adds a ton of complexity to the
code.  It forces us to open-code the entire format. 

Here's what I would suggest: at any point during restore, we should be
able to read two kinds of objects:

	1. the next expected "deterministic" object
	2. something to go into the objhash

We can encapsulate the objhash object reads inside of the normal
cr_read_obj() calls.  If they see the object that we're looking for then
we return that.  If we see an objhash object, then we put it in the
objhash and retry.  

-- Dave
