From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/7] [RFC] Support multiply-bindable cgroup subsystems
Date: Wed, 18 Mar 2009 10:39:27 +0800
Message-ID: <49C05EDF.5010607@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>	
	<20090312105147.24154.62638.stgit@menage.corp.google.com>	
	<49BF4744.5060309@cn.fujitsu.com> <49C057EB.1000307@cn.fujitsu.com>
	<6599ad830903171916x7364ec7cw76975d71d5125d82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830903171916x7364ec7cw76975d71d5125d82-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Mar 17, 2009 at 7:09 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> Ah, I just notice debug_subsys will never be in rootnode.
> 
> Right - this is the first of the "Open Issues" that I mentioned in the
> patch. The question is how to display the multiply-bindable subsystems
> in /proc/cgroup in a way that won't break backward-compatibility.
> Options include:
> 
> - always display one line for each subsystem; if a subsystem is
> multiply-bindable then the "hierarchy id" and "num cgroups" columns
> may be empty or have multiple (comma or slash-separated?) values
> 

Then "hierarchy id" is no long a single number..

> - for a multiply-bindable subsystem, have a header line to indicate
> that the subsystem exists, and then a separate line for each bound
> instance of the subsystem.
> 

I think it's better to show every subsystems including debug_subsys in
/proc/cgroups, and show exactly n lines of debug_susys if we have n
hierarcies with debug_subsys binded, but no header line.

> Either of these could confuse existing userspace parsers, but I'm not

And some cgroup test programs, like controller tests in ltp and some
test programs that I wrote, but they are ok for this change.

> sure that any exist other than libcgroup, and I don't think it's in
> wide use yet.
> 
