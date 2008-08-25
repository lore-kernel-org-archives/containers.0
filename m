From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 8/9] File descriprtors - dump state
Date: Sun, 24 Aug 2008 23:28:14 -0400
Message-ID: <48B226CE.2060700__12594.6234599271$1219635030$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202306530.17436@takamine.ncl.cs.columbia.edu>
	<20080821110614.GK581@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821110614.GK581-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Wed, Aug 20, 2008 at 11:07:16PM -0400, Oren Laadan wrote:
>> Dump the files_struct of a task with 'struct cr_hdr_files', followed by
>> all open file descriptors. Since FDs can be shared, they are assigned a
>> tag and registered in the object hash.
>>
>> For each open FD there is a 'struct cr_hdr_fd_ent' with the FD, its tag
>> and its close-on-exec property. If the FD is to be saved (first time)
>> then this is followed by a 'struct cr_hdr_fd_data' with the FD state.
>> Then will come the next FD and so on.
>>
>> This patch only handles basic FDs - regular files, directories and also
>> symbolic links.
> 
> [...]

[...]

> 
>> @@ -114,4 +125,24 @@ struct cr_hdr_vma {
>>
>>  } __attribute__ ((aligned (8)));
>>
>> +struct cr_hdr_files {
>> +	__u32 tag;	/* sharing identifier */
>> +	__u32 nfds;
>> +} __attribute__ ((aligned (8)));
>> +
>> +struct cr_hdr_fd_ent {
>> +	__u32 tag;
>> +	__u16 fd;
>> +	__u16 close_on_exec;
>> +} __attribute__ ((aligned (8)));
>> +
>> +struct cr_hdr_fd_data {
>> +	__u16 how;
>> +	__u16 f_mode;
>> +	__u32 f_flags;
>> +	__u32 f_uid, f_gid;
> 
> We are not at a 64bits boundary here. Should add one __32 padding or reorder the
> fields.

Actually this is ok - note there are two fields on fourth row. I'll
change to one field per row so it's easily seen.

Thanks,

Oren.
