From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4 cgroup/for-3.7] cgroup: mark subsystems with broken
	hierarchy support and whine if cgroups are nested for them
Date: Tue, 18 Sep 2012 09:27:04 -0700
Message-ID: <CAOS58YPjEE-+Kak_XidAd5qT84pZKt_z=4_MXadHYvzP+yZ5+Q__38646.6094213121$1347985641$gmane$org@mail.gmail.com>
References: <20120913183402.GG7677@google.com>
	<20120913192058.GH7677@google.com>
	<20120914190608.GM17747@google.com>
	<20120918150404.GC19840@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120918150404.GC19840-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Michal.

On Tue, Sep 18, 2012 at 8:04 AM, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> wrote:
>> The branch is based on top of the current mainline (fbcbe2b3c 3.6-rc5)
>> and only contains hierarchy related changes.
>
> This is not very much mm git tree friendly because I would have to pull
> a lot just to merge a single commit... It would have been much nicer if
> you based it on the last major release (it applies cleanly on top of
> 3.5). mm git tree tries to get as few (unrelated) changes as possible on
> top of the last major release.

Hmmm... I thought you explicitly requested it to be based on -rc5.
Maybe I misread... and yes I did. I read 3.5 as 3.6-rc5.

>> The branch will be kept stable unless I do something completely
>> stupid, so please feel free to pull into other trees as necessary.
>
> Anyway, keep it this way for now (as we are getting close to the end of
> 3.6). I have cherry-picked 8c7f6edb for now and use the branch after 3.6
> is out.

It's single commit.  Rebasing is not a problem.

Thanks.

-- 
tejun
