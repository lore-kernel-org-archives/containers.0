From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support
Date: Thu, 04 Jun 2009 13:20:35 -0700
Message-ID: <877hzrkay4.fsf@caffeine.danplanet.com>
References: <1244042305-7770-1-git-send-email-danms@us.ibm.com>
	<20090604151923.GA29519@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090604151923.GA29519-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Thu\, 4 Jun 2009 10\:19\:23 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

SH> I do think that the following should be moved into network
SH> headers:

>> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
SH> ...
>> @@ -248,6 +262,11 @@ struct ckpt_hdr_file_pipe {
>> __s32 pipe_objref;
>> } __attribute__((aligned(8)));
>> 
>> +struct ckpt_hdr_file_socket {
>> +	struct ckpt_hdr_file common;
>> +	__u16 family;
>> +} __attribute__((aligned(8)));
>> +
>> struct ckpt_hdr_file_pipe_state {
>> struct ckpt_hdr h;
>> __s32 pipe_len;
>> @@ -394,4 +413,56 @@ struct ckpt_hdr_ipc_sem {
>> #define CKPT_TST_OVERFLOW_64(a, b) \
>> ((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
>> 
>> +struct ckpt_hdr_socket {
>> +	struct ckpt_hdr h;
>> +
>> +	/* sock_common */
>> +	__u16 family;
>> +	__u8 state;
>> +	__u8 reuse;
>> +	__u32 bound_dev_if;
>> +
>> +	/* sock */
>> +	__u8 protocol;
>> +	__u16 type;
>> +	__u8 sock_state;
>> +	__u8 shutdown;
>> +	__u8 userlocks;
>> +	__u8 no_check;
>> +	__u32 err;
>> +	__u32 err_soft;
>> +	__u32 priority;
>> +	__u64 rcvlowat;
>> +	__u64 rcvtimeo;
>> +	__u64 sndtimeo;
>> +	__u16 backlog;
>> +	__s32 rcvbuf;
>> +	__s32 sndbuf;
>> +	__u64 flags;
>> +	__u64 lingertime;
>> +
>> +	/* socket */
>> +	__u64 socket_flags;
>> +	__u8 socket_state;
>> +
>> +	/* common to all supported families */
>> +	struct sockaddr laddr;
>> +	struct sockaddr raddr;
>> +	__u32 laddr_len;
>> +	__u32 raddr_len;
>> +
>> +	union {
>> +		struct {
>> +			__u32 this;
>> +			__u32 peer;
>> +		} un;
>> +	};
>> +
>> +} __attribute__ ((aligned(8)));

I think that makes sense.  The (large amount of) changes to add INET
support would seal the deal, I think.  So this goes in something like
include/linux/socket.h?

SH> EXTREME nit: a blank line between the return and the error label.

Ah, oops.

SH> in the CHECKPOINT_SUBTREE case do we want to try to ensure that
SH> sk->peer is owned by another checkpointed task?

That probably wouldn't be too hard, as I can just check pids_arr.

>> +			peer->sk_peercred.pid = task_tgid_vnr(current);

SH> Will the peer's sk_peercred.pid always be current's pid?

That gets set to the pid of whichever side does the connection, in the
normal connect()..accept() case, so I think this is okay.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
