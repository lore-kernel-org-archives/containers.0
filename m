From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 18/18] [RFC] user-cr: Cleanup __filepos
Date: Mon, 28 Mar 2011 14:23:38 -0400
Message-ID: <4D90D22A.5090301@cs.columbia.edu>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<da8b6651fb9271826e35ba47d9e41883b63bfee0.1300382276.git.matthltc@us.ibm.com>
	<4b6b9f5cc66c1675d6249622455709d6c5d586c9.1300382276.git.matthltc@us.ibm.com>
	<65466a734e085f916c776de153dfddf1c60aea7b.1300382276.git.matthltc@us.ibm.com>
	<c0d1aeb2aa40cecab3182ce686833b964cd8c07f.1300382276.git.matthltc@us.ibm.com>
	<79950217f2c66153c2b4b5bfb55bd5f1759b7933.1300382276.git.matthltc@us.ibm.com>
	<4e4459e8d18102996eedb18a216b45b93dc473c2.1300382276.git.matthltc@us.ibm.com>
	<27ba6a5c70b7e4e3aba2f42641b322f7a7bef7ba.1300382276.git.matthltc@us.ibm.com>
	<a62f11e2f3c8fb4d1271414b5ae854c29ee73ae8.1300382276.git.matthltc@us.ibm.com>
	<8db3ca5ee994168916fbb8d36a604c06e18e2c7b.1300382276.git.matthltc@us.ibm.com>
	<b2088002d6b93118cfd333c8920a4126b1c9759a.1300382276.git.matthltc@us.ibm.com>
	<57f87d60d23843cd67929c96d42b238a47b3fd9a.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <57f87d60d23843cd67929c96d42b238a47b3fd9a.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



On 03/17/2011 01:27 PM, Matt Helsley wrote:
> Based on the original commit it's unclear why we didn't go with the far
> simpler approach of using the lseek() system call (or suitably-sized variant)
> to determine the position in the stream where the object was found. This

... because it may be an arbitrary stream, including pipe/socket which
do not support lseek() operation.

> avoids having to spread increments to this global variable into any function
> that might accidentally read the checkpoint image stream and it avoids any
> bugs dealing with error detection, retries, and return values.

That is the reason that __filepos is updated only in a single place -
__image_read() used by all other reads from the image, and only when
the operation succeeded.

I'm not sure what sort of bugs you envision (so to speak) concerning
error detection, retries and return values ?

Oren.


> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  ckptinfo.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/ckptinfo.c b/ckptinfo.c
> index e7609c0..5eed5ca 100644
> --- a/ckptinfo.c
> +++ b/ckptinfo.c
> @@ -41,7 +41,11 @@ struct args {
>  };
>  
>  int __verbose;
> -unsigned long __filepos;
> +
> +static inline loff_t __filepos(int fd)
> +{
> +	return lseek(fd, 0, SEEK_CUR);
> +}
>  
>  #define VERBOSE(_format, _args...)			\
>  	do {						\
> @@ -182,7 +186,6 @@ static int __image_read(int fd, void *buf, int len)
>  		return -1;
>  	}
>  
> -	__filepos += len;
>  	return len;
>  }
>  
> @@ -195,8 +198,8 @@ static int image_read_obj(int fd, struct ckpt_hdr **hh)
>  	if (ret <= 0)
>  		return ret;
>  
> -	VERBOSE("info: [@%lu] object %3d %s len %d\n",
> -		__filepos, h.type, hdr_to_str(h.type), h.len);
> +	VERBOSE("info: [@%llu] object %3d %s len %d\n",
> +		__filepos(fd), h.type, hdr_to_str(h.type), h.len);
>  
>  	p = malloc(h.len);
>  	if (!p) {
