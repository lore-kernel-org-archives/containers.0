From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: Namespaces exhausted CLONE_XXX bits problem
Date: Tue, 15 Jan 2008 16:51:50 +0100
Message-ID: <478CD696.8090603@fr.ibm.com>
References: <478B76C4.8050804@openvz.org> <478B7DB3.9050702@fr.ibm.com>
	<20080114163246.GA31663@sergelap.austin.ibm.com>
	<478B9345.30004@openvz.org>
	<20080114180748.GA2772@sergelap.austin.ibm.com>
	<478BD5CD.7030607@cs.columbia.edu>
	<1200347674.22674.28.camel@localhost> <478C6E14.1050901@openvz.org>
	<1200388938.22674.58.camel@localhost> <478C7BD1.7040905@openvz.org>
	<20080115150806.GH4453@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080115150806.GH4453-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>> Dave Hansen wrote:
>>> On Tue, 2008-01-15 at 11:25 +0300, Pavel Emelyanov wrote:
>>>> Hmm. I have an idea how to make this w/o a new system call. This might
>>>> look wierd, but. Why not stopple the last bit with a CLONE_NEWCLONE and
>>>> consider the parent_tidptr/child_tidptr in this case as the pointer to 
>>>> an array of extra arguments/flargs?
>>> I guess that does keep us from having to add an _actual_ system call.
>> Exactly!
> 
> I'll be honest, while it's a really neat idea, in terms of code actually
> going into tree I far far prefer a real new syscall.

well, hijacking child_tidptr and adding a new syscall will probably look 
the same internally. so if it ends up that hijacking child_tidptr is not 
acceptable, we won't have much work to plug it in a new syscall.

> But it sounds like I'm the only one so I'll just mention it once and
> then bite my tongue  :)

hold on. this patch has not been sent on lkml@ but it's worth a try :)

C.
