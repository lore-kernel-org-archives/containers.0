From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/7] [RFC] Support multiply-bindable cgroup subsystems
Date: Tue, 17 Mar 2009 19:16:13 -0700
Message-ID: <6599ad830903171916x7364ec7cw76975d71d5125d82@mail.gmail.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
	<20090312105147.24154.62638.stgit@menage.corp.google.com>
	<49BF4744.5060309@cn.fujitsu.com> <49C057EB.1000307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C057EB.1000307-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 17, 2009 at 7:09 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> Ah, I just notice debug_subsys will never be in rootnode.

Right - this is the first of the "Open Issues" that I mentioned in the
patch. The question is how to display the multiply-bindable subsystems
in /proc/cgroup in a way that won't break backward-compatibility.
Options include:

- always display one line for each subsystem; if a subsystem is
multiply-bindable then the "hierarchy id" and "num cgroups" columns
may be empty or have multiple (comma or slash-separated?) values

- for a multiply-bindable subsystem, have a header line to indicate
that the subsystem exists, and then a separate line for each bound
instance of the subsystem.

Either of these could confuse existing userspace parsers, but I'm not
sure that any exist other than libcgroup, and I don't think it's in
wide use yet.

Paul
