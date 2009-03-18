From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Wed, 18 Mar 2009 13:13:33 -0700
Message-ID: <1237407213.8286.198.camel@nimitz>
References: <20090317062754.GA2377@us.ibm.com>
	<20090317063940.GF2377@us.ibm.com>	<49C0B6FF.5030104@cs.columbia.edu>
	<20090318135953.GE22636@us.ibm.com>	<49C1201A.3050604@cs.columbia.edu>
	<20090318171840.GA29523@us.ibm.com> <49C1347F.3000601@cs.columbia.edu>
	<49C153AF.7070504@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C153AF.7070504-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-03-18 at 13:03 -0700, Mike Waychison wrote:
> Polluting the dmesg buffer with messages from common failures (consider 
> a multi-user cluster where checkpoints may or may not succeed) isn't 
> very useful.

Yeah, I've already gotten an earful from Serge and Dan S. about this. :)

Serge suggested that, perhaps, the audit framework could be used.  We
might also use an ftrace buffer if we want to keep a whole ton of
messages around, too.

dmesg is definitely not workable long-term at all.

-- Dave
