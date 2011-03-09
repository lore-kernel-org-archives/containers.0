From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Documentation: cgroups: Add notes on removing PIDs from
	tasks and cgroups requiring setup
Date: Wed, 9 Mar 2011 15:13:34 -0800
Message-ID: <AANLkTinW99M1FBp5gRA=+SsjUWSJBwByurqrsjXKgQ4=__30845.9943662912$1299712565$gmane$org@mail.gmail.com>
References: <1299704969-4485-1-git-send-email-emunson@mgebm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1299704969-4485-1-git-send-email-emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Mar 9, 2011 at 1:09 PM, Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org> wrote:
>
> +Note: To remove a task from a cgroup you must write its PID to the root
> +tasks file.
> +

This isn't really accurate - the root cgroup is a cgroup like all the
others. More accurate would be something like:

Since every task is always a member of exactly one cgroup in each
mounted hierarchy, to remove a task from its current cgroup you must
move it into a new cgroup (possibly the root cgroup) by writing to the
new cgroup's tasks file.

Paul
