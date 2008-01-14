From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Namespaces exhausted CLONE_XXX bits problem
Date: Mon, 14 Jan 2008 13:54:34 -0800
Message-ID: <1200347674.22674.28.camel@localhost>
References: <478B6764.6050300@openvz.org> <478B7549.2020000@fr.ibm.com>
	<478B76C4.8050804@openvz.org> <478B7DB3.9050702@fr.ibm.com>
	<20080114163246.GA31663@sergelap.austin.ibm.com>
	<478B9345.30004@openvz.org>
	<20080114180748.GA2772@sergelap.austin.ibm.com>
	<478BD5CD.7030607@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <478BD5CD.7030607-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-01-14 at 16:36 -0500, Oren Laadan wrote:
> I second the concern of running out of 64 bits of flags. In fact, the
> problem with the flags is likely to be valid outside our context, and
> general to the linux kernel soon. Should we not discuss it there
> too ? 

It would be pretty easy to make a new one expandable:

	sys_newclone(int len, unsigned long *flags_array)

Then you could give it a virtually unlimited number of "unsigned long"s
pointed to by "flags_array".

Plus, the old clone just becomes:

        sys_oldclone(unsigned long flags)
        {
        	do_newclone(1, &flags);
        }

We could validate the flags array address in sys_newclone(), then call
do_newclone().

-- Dave
