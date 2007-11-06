From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: namespaces compatibility list
Date: Tue, 06 Nov 2007 17:46:09 +0100
Message-ID: <47309A51.1050607@fr.ibm.com>
References: <47304729.8000309@openvz.org> <4730640D.9030407@fr.ibm.com>
	<4730655C.8000306@openvz.org> <47308FDB.4010302@fr.ibm.com>
	<473091F9.10406@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473091F9.10406-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Cedric Le Goater wrote:
>> Pavel Emelyanov wrote:
>>> Cedric Le Goater wrote:
>>>> Pavel Emelyanov wrote:
>>>>> Hi guys!
>>>>>
>>>>> As you might have seen, recently there was some spontaneous 
>>>>> discussion about the namespaces-working-together problems.
>>>>>
>>>>> Ted T'so proposed to create some document that describes what
>>>>> problems user may have when he/she creates some new namespace,
>>>>> but keeps others shared. I like this idea, so here's the draft
>>>>> with the problems I currently have in mind and can describe 
>>>>> somewhat audibly - the "namespaces compatibility list".
>>>> that compatibility list could be encoded in the way we check
>>>> the clone flags in copy_process() and unshare(). It would 
>>>> also be good to have it as a comment somewhere in kernel/fork.c
>>> How can we insure, that a new task will not share the files
>>> with its parent to address the PID namespaces vs VFS namespaces
>>> interaction? There's no way to do it. We can only keep them in
>>> one IPC namespace...
>> ? I'm not sure I understand you.
> 
> As far as I understand, you propose the check for the clone flags
> in the copy_process()/sys_unshare() and return -EINVAL for the cases
> we consider to be unsafe. E.g. when a user wants to clone new pid
> namespace, he must clone the ipc namespace as well.

yes.

> But my point is that this check is not enough - user may kill himself
> by cloning a pid namespace and sharing the pids via the filesystem 
> (like with the example with futexes) and there's no way to check for 
> this situation in the copy_process()/sys_unchare.

right. I think we can address Ulrich concerns first because we have 
a solution for it (which looks like unsharing all namespaces at once,
here comes back the container object story :)
 
> I mean that this list cannot be encoded. But we can warn user, that
> some stuff will stop working if he violates some rules.

and then do that for the futexes, which are a real difficult case.

thanks,

C.
