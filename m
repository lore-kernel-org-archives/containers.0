From: chris hyser <chris.hyser-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Thu, 1 Mar 2018 01:46:16 -0500
Message-ID: <efedc38e-a29b-478a-0b1b-d8292b793d3c@oracle.com>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
	<20180226230418.46nczgkh5csakyu7@ast-mbp>
	<CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g@mail.gmail.com>
	<CALCETrXNODxWkcwF-LbXBn+Ju7QJEyi3JR+spsRX4ecg8d1iMQ@mail.gmail.com>
	<CAGXu5j+64WzxjBnpQxYCU50ak+VqVw1y0W+MWygFodxsDqEZRw@mail.gmail.com>
	<db759dd2-31dc-d094-251d-d4c1e8af8704@oracle.com>
	<CAGXu5j+idW9AjZHVdeedqLOFXriObUJLvcw8-9k5WxyQF8EWrg@mail.gmail.com>
	<ddbefdda-f3b8-3956-fa0f-dcba8cf8e7d9@oracle.com>
	<f712a383-8e84-da64-a454-51fdebf28741@iogearbox.net>
	<7fc0fab8-c1bc-bc76-a892-b3faab7d16ad@oracle.com>
	<4fbef77e-92ad-b896-a259-492412ad4c55@oracle.com>
	<19cd2e07-5702-1713-6903-e5667250b09d@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <19cd2e07-5702-1713-6903-e5667250b09d-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/28/2018 02:56 PM, Daniel Borkmann wrote:
> On 02/28/2018 12:55 AM, chris hyser wrote:

>> If you're implying that because seccomp would have it's own verifier and could therefore restrict itself to a subset of eBPF, 
>> therefore any future additions/features to eBPF would not necessarily make seccomp less secure, I mainly agree. Is that th
>> argument?
> 
> Ok, in addition to the current unpriv restrictions imposed by the verifier,
> what additional requirements would you have from your side in order to get
> to semantics that make sense for you wrt seccomp/eBPF? Just trying to
> understand how far we are away from that. Note that not every new feature,
> map or helper is enabled for every program type of course.

Let me try to clarify my argument by laying out my thoughts here (I apologize if it seems pedantic):

The intent of seccomp is to reduce the kernel attack surfaces available to a compromised user program; if you can't make 
a syscall, you can't exploit some lurking security bug.

Now, if I order various possible seccomp implementation choices in terms of minimizing that implementation's kernel 
attack surfaces it might reasonably be:

1) simple bit vector go/no go check (or similar)
2) cBPF like today
3) some restricted subset of eBPF
4) some other or less restricted subset of eBPF
5) all current eBPF
6) eBPF plus future features

The trade-off is that more features equals less security (ie more security risk). The question is do we allow user land 
to decide where they want to be on that scale or do we pick knowing it will be too much for some and too little for 
others. Answering your question therefore requires knowing either where we choose to be on that scale or what options 
and at what granularity we allow user land to choose. In terms of user land options, just choosing between 2 and 5 might 
be enough. I'd favor say 1 and 4 or 1 and 5 as I don't think it unreasonable for the security paranoid to choose 1.

-chrish
