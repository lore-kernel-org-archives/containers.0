From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Namespaces exhausted CLONE_XXX bits problem
Date: Tue, 15 Jan 2008 01:22:18 -0800
Message-ID: <1200388938.22674.58.camel@localhost>
References: <478B6764.6050300@openvz.org> <478B7549.2020000@fr.ibm.com>
	<478B76C4.8050804@openvz.org> <478B7DB3.9050702@fr.ibm.com>
	<20080114163246.GA31663@sergelap.austin.ibm.com>
	<478B9345.30004@openvz.org>
	<20080114180748.GA2772@sergelap.austin.ibm.com>
	<478BD5CD.7030607@cs.columbia.edu>
	<1200347674.22674.28.camel@localhost> <478C6E14.1050901@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <478C6E14.1050901-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-01-15 at 11:25 +0300, Pavel Emelyanov wrote:
> Hmm. I have an idea how to make this w/o a new system call. This might
> look wierd, but. Why not stopple the last bit with a CLONE_NEWCLONE and
> consider the parent_tidptr/child_tidptr in this case as the pointer to 
> an array of extra arguments/flargs?

I guess that does keep us from having to add an _actual_ system call.
Do we make the array something like

	array[] = { orig_tidptr, nr_flags, actual flags... };

?

-- Dave
