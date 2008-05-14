From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC/PATCH 1/8]: CGroup Files: Add locking mode to cgroups control
	files
Date: Wed, 14 May 2008 09:30:40 +0800
Message-ID: <482A40C0.8030708__24503.3965715722$1210728939$gmane$org@cn.fujitsu.com>
References: <20080513063707.049448000@menage.corp.google.com>	
	<20080513071522.133586000@menage.corp.google.com>	
	<48295E11.2000003@cn.fujitsu.com>
	<6599ad830805131407y3d94016cn773ba21a42b6098c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830805131407y3d94016cn773ba21a42b6098c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

>>  > @@ -1518,16 +1580,21 @@ static ssize_t cgroup_file_read(struct f
>>  >       struct cftype *cft = __d_cft(file->f_dentry);
>>  >       struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
>>  >
>>  > -     if (!cft || cgroup_is_removed(cgrp))
>>  > +     if (cgroup_is_removed(cgrp))
>>  >               return -ENODEV;
>>  >
>>
>>  This check seems redundant now.
>>
> 
> It's not needed for safety, but it doesn't seem to hurt to check
> cgroup_is_removed() prior to doing any copying, since we'll fail after
> copying anyway if cgroup_is_removed() returns true (once we've taken
> any relevant locks).
> 

It's a bit odd to me that cgroup_is_removed() is removed in cgroup_file_write(),
but it's ressered here.
