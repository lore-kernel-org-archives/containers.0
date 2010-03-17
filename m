From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 2/5] memcg: dirty memory documentation
Date: Wed, 17 Mar 2010 09:48:18 -0800
Message-ID: <49b004811003171048h5f27405oe6ea39a103bc4ee3__40179.8427374617$1268851353$gmane$org@mail.gmail.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-3-git-send-email-arighi@develer.com>
	<20100316164121.024e35d8.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100316164121.024e35d8.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 15, 2010 at 11:41 PM, Daisuke Nishimura
<nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> On Mon, 15 Mar 2010 00:26:39 +0100, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wro=
te:
>> Document cgroup dirty memory interfaces and statistics.
>>
>> Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 36 +++++++++++++++++++++++++++=
+++++++++
>> =A01 files changed, 36 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index 49f86f3..38ca499 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -310,6 +310,11 @@ cache =A0 =A0 =A0 =A0 =A0 =A0- # of bytes of page c=
ache memory.
>> =A0rss =A0 =A0 =A0 =A0 =A0- # of bytes of anonymous and swap cache memor=
y.
>> =A0pgpgin =A0 =A0 =A0 =A0 =A0 =A0 =A0 - # of pages paged in (equivalent =
to # of charging events).
>> =A0pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged out (equivalent=
 to # of uncharging events).
>> +filedirty =A0 =A0- # of pages that are waiting to get written back to t=
he disk.
>> +writeback =A0 =A0- # of pages that are actively being written back to t=
he disk.
>> +writeback_tmp =A0 =A0 =A0 =A0- # of pages used by FUSE for temporary wr=
iteback buffers.
>> +nfs =A0 =A0 =A0 =A0 =A0- # of NFS pages sent to the server, but not yet=
 committed to
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 the actual storage.

Should these new memory.stat counters (filedirty, etc) report byte
counts rather than page counts?  I am thinking that byte counters
would make reporting more obvious depending on how heterogeneous page
sizes are used. Byte counters would also agree with /proc/meminfo.
Within the kernel we could still maintain page counts.  The only
change would be to the reporting routine, mem_cgroup_get_local_stat(),
which would scale the page counts by PAGE_SIZE as it does for for
cache,rss,etc.

--
Greg
