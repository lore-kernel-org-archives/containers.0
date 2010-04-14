From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Wiki for LXC with Checkpoint/Restart
Date: Wed, 14 Apr 2010 13:43:50 -0700
Message-ID: <20100414204350.GB24411@us.ibm.com>
References: <20100412222727.GA5759@us.ibm.com>
	<1271275047.18251.111.camel@localhost>
	<87ljcpajog.fsf@caffeine.danplanet.com>
	<1271276208.18251.119.camel@localhost>
	<87hbndaik9.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87hbndaik9.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dan Smith [danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| NL> Are the patches in a publicly available branch?
| 
| Not that I'm aware of, because they're wrapped in with some functional
| changes and cleanups to the way the stuff is called.  I suppose I
| could hack in some #ifdef's to the public bits to fix that, if
| needed.

Do we run into the compile error only if some config tokens are selected ?
Given that the instructions in the wiki don't use networking heavily,
if we have a simple hack for the commit in the wiki, we could post a
kernel patch to the lxc.sf.net directory.
| 
| -- 
| Dan Smith
| IBM Linux Technology Center
| email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
