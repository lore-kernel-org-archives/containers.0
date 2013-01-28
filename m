From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 3/6] userns: Recommend use of memory control groups.
Date: Mon, 28 Jan 2013 09:18:42 -0800
Message-ID: <874ni1ql8t.fsf__47367.2843458646$1359393564$gmane$org@xmission.com>
References: <87ehh8it9s.fsf@xmission.com> <87txq4hedl.fsf@xmission.com>
	<51062AB5.9060203@parallels.com> <51062DA8.1060804@parallels.com>
	<87k3qxu3kp.fsf@xmission.com> <51063558.1010402@parallels.com>
	<87k3qxs2ko.fsf@xmission.com> <5106A941.6060403@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5106A941.6060403-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Lord Glauber Costa of Sealand's
	message of "Mon, 28 Jan 2013 20:37:21 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Kerrisk <mtk-T1hC0tSOHrs@public.gmane.org>
List-Id: containers.vger.kernel.org

Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

>> For two pieces of software that were designed to complement each other
>> I find it a bit surprising how many people (including myself) need the
>> connection made that memory control groups and user namespaces should go
>> together.
>
> Well, I've manifested many times in here that I am less than satisfied
> about the fact that the connection between namespaces and cgroups are so
> loose. There are many situations, like virtualizing the proc files and
> friends where I believe we could benefit from having the information
> about whether or not cgroups and namespaces are used at the same time.

Certainly there are issues where there are not good ways for
applications to discover how much memory or how many cpus are available
for the application to run on.  And applications resort to looking at
how much memory or how many cpus are in the box.

The only way I can think of to make things better is to provide good
alternatives that people can look at and make limiting applications
common enough that the bugs start getting fixed.  And possibly doing the
work to fix a common library or two.

Eric
