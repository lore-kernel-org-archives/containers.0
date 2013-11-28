From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-3.13-fixes] cgroup: fix cgroup_subsys_state leak for
	seq_files
Date: Thu, 28 Nov 2013 17:06:33 +0800
Message-ID: <52970799.8060603@huawei.com>
References: <20131127231550.GE13098@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131127231550.GE13098-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/11/28 7:15, Tejun Heo wrote:
> If a cgroup file implements either read_map() or read_seq_string(),
> such file is served using seq_file by overriding file->f_op to
> cgroup_seqfile_operations, which also overrides the release method to
> single_release() from cgroup_file_release().
> 
> Because cgroup_file_open() didn't use to acquire any resources, this
> used to be fine, but since f7d58818ba42 ("cgroup: pin
> cgroup_subsys_state when opening a cgroupfs file"), cgroup_file_open()
> pins the css (cgroup_subsys_state) which is put by
> cgroup_file_release().  The patch forgot to update the release path
> for seq_files and each open/release cycle leaks a css reference.
> 
> Fix it by updating cgroup_file_release() to also handle seq_files and
> using it for seq_file release path too.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org # v3.12
> ---
> Hello,
> 
> I'm applying this to for-3.13-fixes right away so that I can push it
> out to Linus tomorrow along with other fixes.
> 

That's fine.

bwt, I'll finish reviewing the cgroup pidlist patchset tomorrow.
